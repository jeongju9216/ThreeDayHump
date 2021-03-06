//
//  SceneDelegate.swift
//  ThreeDayHump
//
//  Created by 유정주 on 2022/01/02.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        setupVersion()
        
        guard let sceneWindow = (scene as? UIWindowScene) else {
            return
        }
        
        window = UIWindow(windowScene: sceneWindow)
        
        setupRootViewController()
        
        window?.makeKeyAndVisible()
    }
    
    func setupRootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
        
        let goalViewController = storyboard.instantiateViewController(withIdentifier: "GoalViewController")
        let threeDayViewController = storyboard.instantiateViewController(withIdentifier: "ThreeDayViewController")
        
        let navigation = storyboard.instantiateViewController(withIdentifier: "MoreNavigationController") as! UINavigationController
        
        if let goal = UserDefaults.standard.string(forKey: "goal"),
           !goal.isEmpty {
            let day = UserDefaults.standard.integer(forKey: "day")
            
            print("Goal: \(goal) / Day: \(day)")
            Goal.shared.goal = goal
            Goal.shared.day = day

            tabBarController?.setViewControllers([threeDayViewController, navigation], animated: false)
        } else {
            print("Goal is nil or Empty")
            tabBarController?.setViewControllers([goalViewController, navigation], animated: false)
        }
        
        window?.rootViewController = tabBarController
    }
    
    func setupVersion() {
        BaseData.shared.version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        BaseData.shared.appStoreVersion = loadAppStoreVersion()
        print("version: \(BaseData.shared.version) / appStoreVersion: \(BaseData.shared.appStoreVersion)")
    }
    
    func loadAppStoreVersion() -> String {
        let appStoreUrl = "http://itunes.apple.com/kr/lookup?bundleId=\(BaseData.shared.bundleID)"

        guard let url = URL(string: appStoreUrl),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            return ""
        }
                
        guard let appStoreVersion = results[0]["version"] as? String else {
            return ""
        }
                        
        return appStoreVersion
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        notificationCenter.removeAllPendingNotificationRequests()
        if !Goal.shared.isDone {
            if let goal = Goal.shared.goal, !goal.isEmpty {
                sendNoti(body: "Noti 1", hour: 10)
                sendNoti(body: "Noti 2", hour: 18)
            }
        }
    }

    func sendNoti(body: String, hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "작심 \(Goal.shared.day+1)일 도전 중!!"
        content.body = body
        content.sound = .default
        
        let date = Date()
        var dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        dateComponents.hour = hour
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                
            }
        }
    }
}

