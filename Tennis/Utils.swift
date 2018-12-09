//
//  Utils.swift
//  Tennis
//
//  Created by Alvaro Ruiz on 25/07/17.
//  Copyright © 2017 Alvaro Ruiz. All rights reserved.
//

import Foundation
import UIKit
import  os.log


public class Utils{
    
    //Gray
    static let colorDefault = "d6d6d6"
    static let colorAlternate = "eaeaea"
    static let colorViewBG = "6c6d6d"
    static let colorLabel = "2d2d2d"
    
    //Blue
    //    static let colorDefault = "222542"
    //    static let colorAlternate = "393d5b"
    //    static let colorViewBG = "020416"
    //    static let colorLabel = "a3582a"
    
    
    static let colorTopMenuBG = "ffffff"
    static let colorTopMenu = "ffffff"
    static let colorImageBorder = UIColor(hexString: "6c6d6d")
    
     static func saveUser(_ user: UserData){
        let success =  NSKeyedArchiver.archiveRootObject(user, toFile: UserData.ArchiveURL.path)
        if(success){
            os_log("User Data saved", log: OSLog.default, type: .debug)
        }
        else{
            os_log("Error: User Data not saved", log: OSLog.default, type: .error)
        }
    }
     static func loadUser() -> UserData {
          guard let user  = NSKeyedUnarchiver.unarchiveObject(withFile: UserData.ArchiveURL.path) as? UserData else {
            return UserData(token: "")
        }
        return user
    }
    public static func setBackground(_ view: UIView){
        
        setBackground(view, nil)
    }
    public static func setBackground(_ view: UIView, _ indexPath: IndexPath?){
        
        var colorCurrent = ""
        if indexPath == nil
        {
            colorCurrent = colorDefault
        }
        else{
            
            if indexPath!.row % 2 == 0{
                colorCurrent = colorDefault
            }
            else{
                colorCurrent = colorAlternate
            }
            
        }
        view.layer.backgroundColor = UIColor(hexString: colorCurrent).cgColor
    }
    
    
    public static func setBackgroundLight(_ view: UIView){
        
        view.layer.backgroundColor = UIColor(hexString: colorAlternate).cgColor
        
        
    }
    public  static func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    public static func setLabelColor(_ views: [UIView]){
        
        for view in views{
            
            if ((view as? UILabel) != nil) {
                let label = view as! UILabel
                label.textColor = UIColor(hexString: colorLabel)
            }
            else{
                setLabelColor(view.subviews)
                
            }
        }
    }
    public static func getDate(_ date: String) -> Date?{
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let dateObj = dateFormat.date(from: date.substring(to: 10))
        return dateObj
    }
   }
public class JsonData{
    
    var jsonArray: [Any]?
    
    public init(_ url: String) {
        
       let semaphore =  DispatchSemaphore(value: 0)
        let apiUrl = url
        guard let url = URL(string: apiUrl) else {
            print("Error creating the url")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            
            guard error == nil else{
                print("Null error")
                return
            }
            guard let responseData = data else {
                print("Null data")
                return
                
            }
            
            do{
                self.jsonArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [Any]
            semaphore.signal()
            }
            catch{
                
            }
            
        })
        task.resume()
        semaphore.wait()
    }
}
public extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSAttributedStringKey.font.rawValue : UIFont(name: "AvenirNext-Medium", size: 12)!]
        //let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        //self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}
extension UIViewController{
    func baseSetup(){
        
        let img = UIImageView(image: UIImage(named: "Logo"))
        img.contentMode = .scaleAspectFit
        
        let logo =  UIBarButtonItem(customView: img)
        
        navigationItem.rightBarButtonItem = logo
        
        
        self.view.backgroundColor = UIColor(hexString: Utils.colorViewBG)
        
        Utils.setLabelColor(self.view.subviews)
        
        
    }
    
    
}
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
