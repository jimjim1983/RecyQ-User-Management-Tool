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


struct GroceryItem {
    
    let key: String!
    let name: String!
    let addedByUser: String!
    let ref: Firebase?
    var completed: Bool!
    let amountOfPlastic: Double!
    var amountOfPaper: Double!
    let amountOfTextile: Double!
    let amountOfEWaste: Double!
    let amountOfBioWaste: Double!
    let amountOfIron: Double!
    
    // Initialize from arbitrary data
    init(name: String, addedByUser: String, completed: Bool, key: String = "",  amountOfPlastic: Double, amountOfPaper: Double, amountOfTextile: Double, amountOfEWaste: Double, amountOfBioWaste: Double, amountOfIron: Double) {
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
        self.ref = nil
        self.amountOfPlastic = amountOfPlastic
        self.amountOfPaper = amountOfPaper
        self.amountOfTextile = amountOfTextile
        self.amountOfEWaste = amountOfEWaste
        self.amountOfBioWaste = amountOfBioWaste
        self.amountOfIron = amountOfIron
    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        name = snapshot.value["name"] as? String
        addedByUser = snapshot.value["addedByUser"] as? String
        completed = snapshot.value["completed"] as? Bool
        ref = snapshot.ref
        amountOfPlastic = snapshot.value["amountOfPlastic"] as? Double
        amountOfPaper = snapshot.value["amountOfPaper"] as? Double
        amountOfTextile = snapshot.value["amountOfTextile"] as? Double
        amountOfEWaste = snapshot.value["amountOfEWaste"] as? Double
        amountOfBioWaste = snapshot.value["amountOfBioWaste"] as? Double
        amountOfIron = snapshot.value["amountOfIron"] as? Double
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "completed": completed,
            "amountOfPlastic": amountOfPlastic,
            "amountOfPaper": amountOfPaper,
            "amountOfTextile": amountOfTextile,
            "amountOfEWaste": amountOfEWaste,
            "amountOfBioWaste": amountOfBioWaste,
            "amountOfIron": amountOfIron
        ]
    }
    
}