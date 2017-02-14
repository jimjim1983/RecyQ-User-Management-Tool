
import UIKit
import Foundation

struct Coupon {
    
    //let key: String!
    let uid: String!
    let couponName: String!
    let couponValue: Int!
    let redemeed: Bool!
    
    // Initialize from arbitrary data
    init(/*key: String = "",*/  uid: String, couponName: String, couponValue: Int, redeemed: Bool) {
        //self.key = key
        self.uid = uid
        self.couponName = couponName
        self.couponValue = couponValue
        self.redemeed = redeemed
        //self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        /*key = snapshot.key*/
        couponName = snapshot.value["couponName"] as? String
        couponValue = snapshot.value["couponValue"] as? Int
        uid = snapshot.value["uid"] as? String
        redemeed = snapshot.value["redeemed"] as? Bool
        //ref = snapshot.ref
        
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "couponName": couponName,
            "couponValue": couponValue,
            "uid": uid,
            "redeemed": redemeed
            /*"key": key*/
        ]
    }
}