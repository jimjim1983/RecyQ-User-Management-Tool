//
//  Admin.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 13-04-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

struct Admin {
    let firstName: String
    let lastName: String
    let email: String
    let location: String
    
    func toAnyObject() -> [String: AnyObject] {
        return [
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "email": email as AnyObject,
            "location": location as AnyObject,
        ]
    }
}
