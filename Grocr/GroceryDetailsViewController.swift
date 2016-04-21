//
//  GroceryDetailsViewController.swift
//  Grocr
//
//  Created by Jim Petri on 11/04/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class GroceryDetailsViewController: UIViewController {
    
    var groceryItem: GroceryItem!
    var ref = Firebase(url: "https://recyqdb.firebaseio.com/clients")
    
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var plasticLabel: UILabel!
    @IBOutlet var paperLabel: UILabel!
    @IBOutlet var textileLabel: UILabel!
    @IBOutlet var ironLabel: UILabel!
    @IBOutlet var eWasteLabel: UILabel!
    @IBOutlet var bioWasteLabel: UILabel!
    
    @IBOutlet var plasticTextField: UITextField!
    @IBOutlet var paperTextField: UITextField!
    @IBOutlet var textileTextField: UITextField!
    @IBOutlet var ironTextField: UITextField!
    @IBOutlet var eWasteTextField: UITextField!
    @IBOutlet var bioWasteTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        emailLabel.text = groceryItem.name
        if let amountOfPlastic = groceryItem.amountOfPlastic {
            plasticLabel.text = "\(amountOfPlastic)"
        }
        if let amountOfPaper = groceryItem.amountOfPaper {
            paperLabel.text = "\(amountOfPaper)"
        }
        if let amountOfTextile = groceryItem.amountOfTextile {
            textileLabel.text = "\(amountOfTextile)"
        }
        if let amountOfIron = groceryItem.amountOfIron {
            ironLabel.text = "\(amountOfIron)"
        }
        if let amountOfEWaste = groceryItem.amountOfEWaste {
            eWasteLabel.text = "\(amountOfEWaste)"
        }
        if let amountOfBioWaste = groceryItem.amountOfBioWaste {
            bioWasteLabel.text = "\(amountOfBioWaste)"
        }

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Annuleer", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroceryDetailsViewController.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Opslaan", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroceryDetailsViewController.save))
        
    }
    
    func cancel() {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        
        let name = groceryItem.name
        ref = Firebase(url: "https://recyqdb.firebaseio.com/clients/\(name)")
        
        let amountOfPlastic = groceryItem.amountOfPlastic + ((plasticTextField.text)! as NSString).doubleValue
        ref.childByAppendingPath("amountOfPlastic").setValue(amountOfPlastic)
        
        let amountOfPaper = groceryItem.amountOfPaper + ((paperTextField.text)! as NSString).doubleValue
        ref.childByAppendingPath("amountOfPaper").setValue(amountOfPaper)
        
        let amountOfTextile = groceryItem.amountOfTextile + ((textileTextField.text)! as NSString).doubleValue
        ref.childByAppendingPath("amountOfTextile").setValue(amountOfTextile)
        
        let amountOfIron = groceryItem.amountOfIron + ((ironTextField.text)! as NSString).doubleValue
        ref.childByAppendingPath("amountOfIron").setValue(amountOfIron)
        
        let amountOfEWaste = groceryItem.amountOfEWaste + ((eWasteTextField.text)! as NSString).doubleValue
        ref.childByAppendingPath("amountOfEWaste").setValue(amountOfEWaste)
        
        let amountOfBioWaste = groceryItem.amountOfBioWaste + ((bioWasteTextField.text)! as NSString).doubleValue
        ref.childByAppendingPath("amountOfBioWaste").setValue(amountOfBioWaste)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
