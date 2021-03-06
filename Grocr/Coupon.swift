
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
    
    init(snapshot: FIRDataSnapshot) {
        /*key = snapshot.key*/
        let snapshotValue = snapshot.value as? NSDictionary
        couponName = snapshotValue?["couponName"] as? String
        couponValue = snapshotValue?["couponValue"] as? Int
        uid = snapshotValue?["uid"] as? String
        redemeed = snapshotValue?["redeemed"] as? Bool
        //ref = snapshot.ref
        
    }
    
    func toAnyObject() -> [String: Any] {
        return [
            "couponName": couponName,
            "couponValue": couponValue,
            "uid": uid,
            "redeemed": redemeed
            /*"key": key*/
        ]
    }
}
