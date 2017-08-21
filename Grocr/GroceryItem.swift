/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

enum NearestWasteLocation: String {
    case amsterdamsePoort = "A'damse Poort"
    case hBuurt = "H-Buurt"
    case holendrecht = "Holendrecht"
    case venserpolder = "Venserpolder"
}

struct GroceryItem {
    
    let key: String
    var dateCreated: String?
    let name: String
    let lastName: String?
    let address: String?
    let zipCode: String?
    let city: String?
    let phoneNumber: String?
    let addedByUser: String //email
    let nearestWasteLocation: String?
    let registeredVia: String?
    let didReceiveRecyQBags: Bool?
    let ref: FIRDatabaseReference?
    var completed: Bool
    var amountOfPlastic: Double
    var amountOfPaper: Double
    var amountOfTextile: Double
    var amountOfEWaste: Double
    var amountOfBioWaste: Double
    var amountOfGlass: Double?
    var wasteDepositInfo: [String: Any]?
    let uid: String
    let spentCoins: Int?
    
    // Initialize from arbitrary data
    init(dateCreated: String?, name: String, lastName: String, address: String, zipCode: String, city: String, phoneNumber: String, addedByUser: String, nearestWasteLocation: String, registeredVia: String?, didReceiveRecyQBags: Bool?, completed: Bool, key: String = "",  amountOfPlastic: Double, amountOfPaper: Double, amountOfTextile: Double, amountOfEWaste: Double, amountOfBioWaste: Double, amountOfGlass: Double?, wasteDepositInfo: [String: Any]?, uid: String, spentCoins: Int) {
        self.key = key
        self.dateCreated = dateCreated
        self.name = name
        self.lastName = lastName
        self.address = address
        self.zipCode = zipCode
        self.city = city
        self.phoneNumber = phoneNumber
        self.addedByUser = addedByUser
        self.nearestWasteLocation = nearestWasteLocation
        self.registeredVia = registeredVia
        self.didReceiveRecyQBags = didReceiveRecyQBags
        self.completed = completed
        self.ref = nil
        self.amountOfPlastic = amountOfPlastic
        self.amountOfPaper = amountOfPaper
        self.amountOfTextile = amountOfTextile
        self.amountOfEWaste = amountOfEWaste
        self.amountOfBioWaste = amountOfBioWaste
        self.amountOfGlass = amountOfGlass
        self.wasteDepositInfo = wasteDepositInfo
        self.uid = uid
        self.spentCoins = spentCoins
    }
    //}
    //    extension User {
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as? NSDictionary
        dateCreated = snapshotValue?["dateCreated"] as? String
        name = snapshotValue?["name"] as! String
        lastName = snapshotValue?["lastName"] as? String
        address = snapshotValue?["address"] as? String
        zipCode = snapshotValue?["zipCode"] as? String
        city = snapshotValue?["city"] as? String
        phoneNumber = snapshotValue?["phoneNumber"] as? String
        addedByUser = snapshotValue?["addedByUser"] as! String
        nearestWasteLocation = snapshotValue?["nearestWasteLocation"] as? String
        registeredVia = snapshotValue?["registeredVia"] as? String
        didReceiveRecyQBags = snapshotValue?["didReceiveRecyQBags"] as? Bool
        completed = snapshotValue?["completed"] as! Bool
        ref = snapshot.ref
        amountOfPlastic = snapshotValue?["amountOfPlastic"] as! Double
        amountOfPaper = snapshotValue?["amountOfPaper"] as! Double
        amountOfTextile = snapshotValue?["amountOfTextile"] as! Double
        amountOfEWaste = snapshotValue?["amountOfEWaste"] as! Double
        amountOfBioWaste = snapshotValue?["amountOfBioWaste"] as! Double
        amountOfGlass = snapshotValue?["amountOfGlass"] as? Double
        wasteDepositInfo = snapshotValue?["wasteDepositInfo"] as? [String: Any]
        uid = snapshotValue?["uid"] as! String
        spentCoins = snapshotValue?["uid"] as? Int
    }
    
    func toAnyObject() -> [String: AnyObject] {
        return [
            "dateCreated": dateCreated as AnyObject,
            "name": name as AnyObject,
            "lastName": lastName as AnyObject,
            "address": address as AnyObject,
            "zipCode": zipCode as AnyObject,
            "city": city as AnyObject,
            "phoneNumber": phoneNumber as AnyObject,
            "addedByUser": addedByUser as AnyObject,
            "nearestWasteLocation": nearestWasteLocation as AnyObject,
            "registeredVia": registeredVia as AnyObject,
            "didReceiveRecyQBags": didReceiveRecyQBags as AnyObject,
            "completed": completed as AnyObject,
            "amountOfPlastic": amountOfPlastic as AnyObject,
            "amountOfPaper": amountOfPaper as AnyObject,
            "amountOfTextile": amountOfTextile as AnyObject,
            "amountOfEWaste": amountOfEWaste as AnyObject,
            "amountOfBioWaste": amountOfBioWaste as AnyObject,
            "amountOfGlass": amountOfGlass as AnyObject,
            "wasteDepositInfo": wasteDepositInfo as AnyObject,
            "uid": uid as AnyObject,
            "spentCoins": spentCoins as AnyObject
        ]
    }
}
