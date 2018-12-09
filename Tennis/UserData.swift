//
//  UserData.swift
//  Tennis
//
//  Created by Alvaro Ruiz on 20/02/18.
//  Copyright © 2018 Alvaro Ruiz. All rights reserved.
//

import Foundation
import os.log

class UserData: NSObject, NSCoding{
    
    var token: String
    init(token: String){
        
//        guard !token.isEmpty else {
//            return nil
//        }
        
        self.token = token
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("userData1")
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: PropertyKey.token)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let token = aDecoder.decodeObject(forKey: PropertyKey.token) as? String
            else{
                os_log("Unable to decode token from User Data Object", log: OSLog.default, type: .debug)
                return nil
        }
        
        self.init(token: token)
    }
    struct  PropertyKey {
        
        static let token = "token"
    }

    
}
