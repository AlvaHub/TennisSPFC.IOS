//
//  AppDelegate.swift
//  Tennis
//
//  Created by Alvaro Ruiz on 11/02/18.
//  Copyright © 2018 Alvaro Ruiz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications

struct Offers : Codable{
    let id: Int
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate{
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
        let statusBar = statWindow.subviews[0] as UIView
        statusBar.backgroundColor = UIColor(hexString: "303030")
        
        //FIREBASE
        FirebaseApp.configure()
        
        //UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh , object: nil)
        
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound])
        { (success, error) in
            
            if(error == nil){
                print("Notification Authorized")
            }
        }
        //Save Token
        //        let refreshToken = InstanceID.instanceID().token()!
        //        let user = Utils.loadUser()
        //        user.token = refreshToken
        //        Utils.saveUser(user)
        //        print(user.token)
        
        application.registerForRemoteNotifications()
        
        
        
        
        return  true
        
    }
    @objc func receiveNotification(notification: Notification) {
        //NUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    func applicationDidFinishLaunching(_ application: UIApplication) {
        //print("FINISH")
        clearBadge()
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //FIREBASE
        firebaseDisableDirectChannel()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        print("PUSH FROM BACKGROUND")
        
        
        if userInfo["page"] as! String == "/remove-notification"{
            
            let NotificationIdToRemove = Int(userInfo["id"] as! String)!
            UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (notifications) in
                
                for x in notifications{
                    if x.request.content.userInfo["page"] as! String == "/player-finder" &&
                        Int(x.request.content.userInfo["id"] as! String)! == NotificationIdToRemove {
                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [x.request.identifier])
                        UserDefaults.standard.removeObject(forKey: x.request.identifier)
                        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1
                        //print("Removed " + String(NotificationIdToRemove))
                    }
                }
            })
            completionHandler(.newData)
        }
        else{
            //            let not = UNMutableNotificationContent()
            //            not.title = "This is Local"
            //            not.body = "This is Body Local"
            //
            //            not.userInfo["page"] = "/player-finder"
            //            not.userInfo["id"] = "1"
            //            let request = UNNotificationRequest(identifier: "1", content: not, trigger: nil)
            //            UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            //                if error == nil{
            //                    UserDefaults.standard.set("1",forKey: "1")
            //                }
            //
            //            })
            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            completionHandler(.noData)
        }
        
    }
    func ReadOffers(_ notifications : [UNNotification]){
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        let session = URLSession(configuration: configuration)
        let url = URL(string: "https://tennisapi.websiteseguro.com/combo/club")!
        session.dataTask(with: url){(data, response, error) in
            
            if error == nil{
                let decoder = JSONDecoder()
                do{
                    let items = try decoder.decode([Offers].self, from: data!)
                    for item in items{
                        for x in notifications{
                            if x.request.content.userInfo["page"] as! String == "/player-finder" &&
                                Int(x.request.content.userInfo["id"] as! String)! == item.id {
                                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [x.request.identifier])
                                //print("Removed " + String(item.id))
                                
                            }
                        }
                    }
                }
                catch{  }
            }
            else{ }
            }.resume()
    }
    //Foreground: Make the notification appears and whe app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 5
        //        let aps = data[AnyHashable("aps")] as? NSDictionary,
        //        let alert = aps["alert"] as? NSDictionary,
        //        let body = alert["body"] as? String,
        //        let title = alert["title"] as? String
        completionHandler([.alert, .sound, .badge])
        print("Will Present Delegate")
    }
    //When notification is tapped, both back and front
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 2
        
        completionHandler()
        print("Will Receive Delegate")
        print(response.notification.request.content.userInfo)
        //notificationAction(response.notification.request.content.userInfo)
        
    }
    
    func notificationAction(_ data: [AnyHashable: Any]){
        
        //        let aps = data["aps"] as! NSDictionary
        //        let alert = aps["alert"] as? NSDictionary
        //        let page = data["page"] as! String
        //        let myURL = URL(string: self.url + "/" + page)
        //        let myRequest = URLRequest(url: myURL!)
        //        webView.load(myRequest)
        //
        //        let app = UIApplication.shared
        //        app.applicationIconBadgeNumber = 0
        
        
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        clearBadge()
    }
    func clearBadge(){
        let application = UIApplication.shared
        print(application.applicationIconBadgeNumber)
        application.applicationIconBadgeNumber = 0
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //FIREBASE
        firebaseEnableDirectChannel()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    @objc func refreshToken(notification: Notification){
        
//        let refreshToken = InstanceID.instanceID().token()!
//        print("*** \(refreshToken) ***")
//
//        //Save Token
//        let user = Utils.loadUser()
//        user.token = refreshToken
//        Utils.saveUser(user)
//
//        (self.window?.rootViewController as! ViewController).webviewSendData(["token" : user.token])
//
//        firebaseEnableDirectChannel()
        
    }
    func firebaseEnableDirectChannel(){
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    func firebaseDisableDirectChannel(){
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    
    
}

