
import SwiftUI

@available(iOS 14.0, *)
struct Splash: View {
    
    @StateObject private var controller = AccessController()
    @State private var remoteURL: URL?
    @State private var showLoader = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            if remoteURL == nil && !showLoader {
                DashboardView().ignoresSafeArea()
            }
            
            if let u = remoteURL {
                SecureWebView(url: u, loading: $showLoader)
                    .edgesIgnoringSafeArea(.all)
                    .statusBar(hidden: true)
            }
            
            if showLoader {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.8)
                    )
            }
        }
        .onReceive(controller.$current) { status in
            switch status {
            case .validating:
                showLoader = true
            case .approved(_, let url):
                remoteURL = url
                showLoader = false
            case .useNative:
                remoteURL = nil
                showLoader = false
            case .idle:
                break
            }
        }
        .onAppear {
            showLoader = true
            controller.beginCheck()
        }
    }
}
