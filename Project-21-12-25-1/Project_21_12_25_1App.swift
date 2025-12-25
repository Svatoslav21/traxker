
import SwiftUI
import Firebase
import Adapty
import AdaptyUI
import UIKit
import UserNotifications
import AppsFlyerLib


@main
struct Project_21_12_25_1App: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    Task {
                        await NotificationManager.shared.requestAuthorization()
                        // Загружаем статус подписки при запуске
                        await SubscriptionManager.shared.loadSubscriptionStatus()
                    }
                }
        }
    }
}



final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, AppsFlyerLibDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()

        AdaptyUI.activate()
        Adapty.activate("public_live_RzrYDLBV.x15sUnwPSFPZcOhqIoGO")
        
        // Инициализация AppsFlyer
        setupAppsFlyer()
        
        // Устанавливаем delegate для обработки уведомлений в foreground
        UNUserNotificationCenter.current().delegate = self

        return true
    }
    
    // Настройка AppsFlyer
    private func setupAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "hBSBjvJhD6YoaKYnhGhPuG"
        // TODO: Замените на реальный App Store ID вашего приложения
        // AppsFlyerLib.shared().appleAppID = "YOUR_APP_STORE_ID"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false // Установите true для тестирования
        
        // Запускаем AppsFlyer
        AppsFlyerLib.shared().start()
    }
    
    // MARK: - AppsFlyerLibDelegate
    
    // Получение атрибуции
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        // Обработка успешного получения атрибуции
        print("✅ AppsFlyer: Conversion data received")
        
        // Можно отправить данные в Firebase или Adapty
        if let status = conversionInfo["af_status"] as? String {
            print("📊 AppsFlyer status: \(status)")
        }
        
        if let mediaSource = conversionInfo["media_source"] as? String {
            print("📊 AppsFlyer media source: \(mediaSource)")
        }
        
        if let campaign = conversionInfo["campaign"] as? String {
            print("📊 AppsFlyer campaign: \(campaign)")
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        // Обработка ошибки получения атрибуции
        print("❌ AppsFlyer: Conversion data error - \(error.localizedDescription)")
    }
    
    // Получение данных о глубоких ссылках
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        // Обработка глубоких ссылок
        print("🔗 AppsFlyer: Deep link data received")
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        // Обработка ошибки глубоких ссылок
        print("❌ AppsFlyer: Deep link error - \(error.localizedDescription)")
    }
    
    // Показываем уведомления, даже когда приложение в foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Показываем уведомление с звуком и badge, даже если приложение активно
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    // MARK: - Deep Linking
    
    // Обработка URL schemes
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: nil, withAnnotation: nil)
        return true
    }
    
    // Обработка Universal Links
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
}
