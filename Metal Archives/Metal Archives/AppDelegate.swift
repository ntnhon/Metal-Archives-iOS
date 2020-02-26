//
//  AppDelegate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import Alamofire
import Toaster
import SDWebImage
import Firebase
import Crashlytics
import UserNotifications
import Siren
import FirebaseMessaging
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SearchHistory")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.initAppSettings()
        self.initAppearance()
        self.initSlideMenuController()
        self.askForReview()
        self.checkNewVersion()
        application.registerForRemoteNotifications()
        
        return true
    }
}

//MARK: Left menu
extension AppDelegate {
    fileprivate func initSlideMenuController() {
        let leftMenuViewController = UIStoryboard(name: "LeftMenu", bundle: Bundle.main).instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
        let homepageNavigationViewController = UIStoryboard(name: "Home", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomepageNavigationController") as! UINavigationController
        SlideMenuOptions.leftViewWidth = 250
        SlideMenuOptions.contentViewOpacity = 0.3
        // Prevent user from swiping menu up and down and closing the slide menu in the same time
        SlideMenuOptions.panGesturesEnabled = false
        SlideMenuOptions.opacityViewBackgroundColor = Settings.currentTheme.slideMenuControllerOpacityBackgroundColor
        
        let slideMenuController = SlideMenuController(mainViewController: homepageNavigationViewController, leftMenuViewController: leftMenuViewController)
        slideMenuController.delegate = leftMenuViewController
    
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }
}

//MARK: - Perform shorcut action
extension AppDelegate {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "search":
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: NSNotification.Name.OpenSearchModule, object: nil)
            }
            Analytics.logEvent("open_from_shortcut", parameters: ["shortcut": "Search"])
            
        case "random":
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: NSNotification.Name.ShowRandomBand, object: nil)
            }
            Analytics.logEvent("open_from_shortcut", parameters: ["shortcut": "Random"])
            
        default:
            break
        }
    }
}

//MARK: - Perform url scheme action
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        switch url.host {
        case "band":
            let bandURLString = url.absoluteString.replacingOccurrences(of: "ma://band/", with: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: NSNotification.Name.ShowBandDetail, object: bandURLString)
            }
            Analytics.logEvent("open_from_widget", parameters: ["widget_item": "Band"])
            
        case "review":
            let reviewURLString = url.absoluteString.replacingOccurrences(of: "ma://review/", with: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: NSNotification.Name.ShowReviewDetail, object: reviewURLString)
            }
            Analytics.logEvent("open_from_widget", parameters: ["widget_item": "Review"])
            
        case "release":
            let releaseURLString = url.absoluteString.replacingOccurrences(of: "ma://release/", with: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: NSNotification.Name.ShowReleaseDetail, object: releaseURLString)
            }
            Analytics.logEvent("open_from_widget", parameters: ["widget_item": "Release"])
            
        default:
            break
        }
        
        return true
    }
}

//MARK: Network Reachability
//extension AppDelegate {
//    private func addNetworkReachabilityListener() {
//        self.networkReachabilityManager?.listener = { status in
//            switch status {
//            case .reachable(_):
//                NotificationCenter.default.post(name: .InternetIsReachable, object: nil)
//            default:
//                NotificationCenter.default.post(name: .InternetIsUnreachable, object: nil)
//            }
//        }
//        self.networkReachabilityManager?.startListening()
//    }
//}

//MARK: - Appearance
extension AppDelegate {
    private func initAppSettings() {
        UserDefaults.registerDefaultValues()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        Settings.currentTheme = UserDefaults.selectedTheme()
        Settings.currentFontSize = UserDefaults.selectedFontSize()
        Settings.thumbnailEnabled = UserDefaults.thumbnailEnabled()
        
        SDWebImageManager.shared().imageDownloader?.maxConcurrentDownloads = 10
        
        //Register for Push Notification
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_,_ in
            
        })
        Messaging.messaging().delegate = self
        
        //Log app settings
        switch Settings.currentTheme! {
        case .default: Analytics.logEvent("use_theme_default", parameters: nil)
        case .light: Analytics.logEvent("use_theme_light", parameters: nil)
        case .vintage: Analytics.logEvent("use_theme_vintage", parameters: nil)
        case .unicorn: Analytics.logEvent("use_theme_unicorn", parameters: nil)
        }
        
        if UserDefaults.thumbnailEnabled() {
            Analytics.logEvent("enabled_thumbnail", parameters: nil)
        } else {
            Analytics.logEvent("disabled_thumbnail", parameters: nil)
        }
        
        switch Settings.currentFontSize! {
        case .default: Analytics.logEvent("use_font_size_default", parameters: nil)
        case .medium: Analytics.logEvent("use_font_size_medium", parameters: nil)
        case .large: Analytics.logEvent("use_font_size_large", parameters: nil)
        }
        
        if UserDefaults.choosenWidgetSections().count == 1 {
            Analytics.logEvent("today_widget_1_section", parameters: ["widget_name": UserDefaults.choosenWidgetSections()[0].description])
        } else if UserDefaults.choosenWidgetSections().count == 2 {
            let widgetNames = UserDefaults.choosenWidgetSections().map({$0.description}).joined(separator: ", ")
            Analytics.logEvent("today_widget_2_sections", parameters: ["widget_name": widgetNames])
        }
        
        Analytics.logEvent("num_of_sessions", parameters: ["count": UserDefaults.numberOfSessions()])
    }
    
    private func initAppearance() {
        window?.tintColor = Settings.currentTheme.titleColor
        
        ToastView.appearance().font = UIFont.systemFont(ofSize: 18, weight: .medium)
        ToastView.appearance().bottomOffsetLandscape = 50
        ToastView.appearance().bottomOffsetPortrait = 70
        ToastView.appearance().textColor = Settings.currentTheme.backgroundColor
        ToastView.appearance().backgroundColor = Settings.currentTheme.bodyTextColor
        
        if #available(iOS 13.0, *) {
            UISegmentedControl.appearance().backgroundColor = Settings.currentTheme.secondaryTitleColor
            UISegmentedControl.appearance().selectedSegmentTintColor = Settings.currentTheme.titleColor
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor], for: .normal)
        }
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
}

//MARK: - MessagingDelegate
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
    }
}

//MARK: - Ask for review
extension AppDelegate {
    private func askForReview() {
        defer {
            UserDefaults.increaseNumberOfSessions()
        }
        
        let numberOfSessions = UserDefaults.numberOfSessions()
        if (numberOfSessions % 20 == 0) && !UserDefaults.didMakeAReview() {
            // Continously ask for review after every 20 usages
            // Prompt 1 minute after app launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                NotificationCenter.default.post(name: NSNotification.Name.AskForReview, object: nil)
            }
        }
    }
}

//MARK: - Check new version
extension AppDelegate {
    private func checkNewVersion() {
        Siren.shared.wail(performCheck: PerformCheck.onForeground) { results in
            switch results {
            case .success(let updateResults):
                switch updateResults.alertAction {
                case .appStore:
                    Analytics.logEvent("open_app_store_to_update", parameters: nil)
                case .nextTime:
                    Analytics.logEvent("update_next_time", parameters: nil)
                case .skip:
                    Analytics.logEvent("skip_update", parameters: nil)
                case .unknown:
                    return
                }
            case .failure(let error):
                Analytics.logEvent("error_checking_update", parameters: ["error": error.localizedDescription])
            }
        }
    }
}

// MARK: - Core Data
extension AppDelegate {
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
