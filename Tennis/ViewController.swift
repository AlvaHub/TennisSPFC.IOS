//
//  ViewController.swift
//  Tennis
//
//  Created by Alvaro Ruiz on 11/02/18.
//  Copyright © 2018 Alvaro Ruiz. All rights reserved.
//

import UIKit
import WebKit
import UserNotifications
import FirebaseMessaging

class ViewController: UIViewController, WKUIDelegate, UNUserNotificationCenterDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
    
    public var webView: WKWebView!
    var url = "https://tennisapi.websiteseguro.com/tennisWeb/"
    
    @IBOutlet weak var viewContainer: UIView!
    
     
    override func viewDidLoad() {
        
      UNUserNotificationCenter.current().delegate = self
     
        
        
        //        let webView = UIView()
        //        webView.backgroundColor = UIColor.red
        //        view.addSubview(webView)
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x:0,y:0,width:view.frame.width,height:view.frame.height), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isHidden = true
        viewContainer.addSubview(webView)
    
        let myURL = URL(string: self.url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
//        var tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
//        tap.numberOfTapsRequired = 1
//
//        tap.delegate = self
//        webView.addGestureRecognizer(tap)
    
       
        webView.translatesAutoresizingMaskIntoConstraints = false
        let l = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: NSLayoutRelation.equal, toItem: viewContainer, attribute: .leading, multiplier: 1, constant: 0)
        let r = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: NSLayoutRelation.equal, toItem: viewContainer, attribute: .trailing, multiplier: 1, constant: 0)
        
        let t = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: NSLayoutRelation.equal, toItem: viewContainer, attribute: .top, multiplier: 1, constant: 0)
        
        let b = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: NSLayoutRelation.equal, toItem: viewContainer, attribute: .bottom, multiplier: 1, constant: 0)
        
        viewContainer.addConstraints([l, r,t,b])
    
        //Badge zero when app is starting
        let application = UIApplication.shared
        print(application.applicationIconBadgeNumber)
        application.applicationIconBadgeNumber = 0
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func handleTap(){
        print("tap")
    }
   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
  
        let user = Utils.loadUser()
        if user.token != "" {
           webviewSendData(["token" : user.token])
        }
    
        //Show starting screen with fade in
        sleep(2)
       
        self.webView.alpha = 0.0
          webView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.webView.alpha = 1.0
        })
    }
   public func webviewSendData(_ dictionary: [String: String]){
        
        self.webView.evaluateJavaScript("getDataFromApp('\(dictionary["token"]!)')",
                                   completionHandler: { (dataReturn: Any, error: Error?) in
                                    print("Return from WebView")
                                    print(dataReturn)
                                    print("Error from WebView")
                                    print(error)
                                    
        })
        //Block finger press on the webview
        self.webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none';document.body.style.webkitUserSelect='none'; document.body.style.mozUserSelect='none'; document.body.style.msUserSelect='none'; document.body.style.userSelect='none'",
                                        completionHandler: { (dataReturn: Any, error: Error?) in

        })
    

    }

    //Foreground: Make the notification appears and whe app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        
        
        print("PUSH FROM FRONT")
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1
        //print(notification.request.content.userInfo)
        
        self.webView.evaluateJavaScript("currentRoute()",
            completionHandler: { (dataReturn: Any, error: Error?) in
                
                let urlTo = notification.request.content.userInfo["page"] as! String
                let urlCurrent = dataReturn as! String
                if urlTo != urlCurrent{
                    completionHandler([.alert, .badge])
                }
        })
        
    }
    //When notification is tapped, both back and front
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("TAPPED")
        //let application = UIApplication.shared
        //print("BADGE")
//        print(application.applicationIconBadgeNumber)
//        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1
//        print(application.applicationIconBadgeNumber)
        
        completionHandler()
        //print("Will Receive")
        //print(response.notification.request.content.userInfo)
        notificationAction(response.notification.request.content.userInfo)
                
    }
    
    func notificationAction(_ data: [AnyHashable: Any]){
     
        let aps = data["aps"] as! NSDictionary
        let alert = aps["alert"] as? NSDictionary
        let page = data["page"] as! String
//        let myURL = URL(string: self.url + "/" + page)
//        let myRequest = URLRequest(url: myURL!)
        
        self.webView.evaluateJavaScript("changeRoute('\(page)')",
            completionHandler: { (dataReturn: Any, error: Error?) in })
        
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Não", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Não", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func dismiss(animated flag: Bool, completion: (() -> Void)?)
    {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    func localNotification(){
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        
        let message = UNMutableNotificationContent()
        message.title = "Convite de Treino II";
        message.body = "Alvaro quer jogar amanhã as 11:00"
        message.badge = 1;
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false )
        
        let request = UNNotificationRequest(identifier: "PlayerFinder", content: message, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
        
    }
}

