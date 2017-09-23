//
//  ShopItem.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 24-07-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

struct ShopItem {
    let key: String?
    let shopName: String
    let validationCode: Int
    let itemName: String
    let detailDescription: String
    let tokenAmount: Int
    let imageString: String
    
    func toAnyObject() -> [String: AnyObject] {
        return [
            "shopName": shopName as AnyObject,
            "validationCode": validationCode as AnyObject,
            "itemName": itemName as AnyObject,
            "detailDescription": detailDescription as AnyObject,
            "tokenAmount": tokenAmount as AnyObject,
            "imageString": imageString as AnyObject,
        ]
    }
}

extension ShopItem {
    init(snapShot: FIRDataSnapshot) {
        key = snapShot.key
        let snapshotValue = snapShot.value as? NSDictionary
        shopName = snapshotValue?["shopName"] as! String
        validationCode =  snapshotValue?["validationCode"] as! Int
        itemName = snapshotValue?["itemName"] as! String
        detailDescription = snapshotValue?["detailDescription"] as! String
        tokenAmount = snapshotValue?["tokenAmount"] as! Int
        imageString = snapshotValue?["imageString"] as! String
    }
}
