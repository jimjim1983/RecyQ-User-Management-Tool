//
//  GroceryDetailsViewController.swift
//  Grocr
//
//  Created by Jim Petri on 11/04/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

var couponName = String()

class GroceryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groceryItem: GroceryItem!
    var ref = FIRDatabase.database().reference(withPath: "clients")
    var couponsRef = FIRDatabase.database().reference(withPath: "coupons")
    //var couponItems = [AnyObject]()
    var couponItems = [FIRDataSnapshot]()
    //var items = [GroceryItem]()

    
    
    
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
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // go trough all coupons and find the one with the same user uid, then add them to the array for the tableview
        self.couponsRef.queryOrdered(byChild: "uid").queryEqual(toValue: groceryItem.uid).observe(.value, with: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.couponItems = snapshots
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        emailLabel.text = groceryItem.name
        
        //        if let emailLabelText = groceryItem.name {
        //            emailLabel.text = "\(emailLabelText)"
        //        }
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Annuleer", style: UIBarButtonItemStyle.plain, target: self, action: #selector(GroceryDetailsViewController.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Opslaan", style: UIBarButtonItemStyle.plain, target: self, action: #selector(GroceryDetailsViewController.save))
        
        let nib = UINib.init(nibName: "CouponsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    func cancel() {
        //print(self.couponItems)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func save() {
        
        let name = groceryItem.name
        ref = FIRDatabase.database().reference(withPath: "clients").child(name!)
        
        let amountOfPlastic = groceryItem.amountOfPlastic + ((plasticTextField.text)! as NSString).doubleValue
        ref.child("amountOfPlastic").setValue(amountOfPlastic)
        
        let amountOfPaper = groceryItem.amountOfPaper + ((paperTextField.text)! as NSString).doubleValue
        ref.child("amountOfPaper").setValue(amountOfPaper)
        
        let amountOfTextile = groceryItem.amountOfTextile + ((textileTextField.text)! as NSString).doubleValue
        ref.child( "amountOfTextile").setValue(amountOfTextile)
        
        let amountOfIron = groceryItem.amountOfIron + ((ironTextField.text)! as NSString).doubleValue
        ref.child( "amountOfIron").setValue(amountOfIron)
        
        let amountOfEWaste = groceryItem.amountOfEWaste + ((eWasteTextField.text)! as NSString).doubleValue
        ref.child( "amountOfEWaste").setValue(amountOfEWaste)
        
        let amountOfBioWaste = groceryItem.amountOfBioWaste + ((bioWasteTextField.text)! as NSString).doubleValue
        ref.child( "amountOfBioWaste").setValue(amountOfBioWaste)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CouponsTableViewCell
        let item = couponItems[indexPath.row]
        cell.nameLabel.text = item.key
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.couponItems[indexPath.row]
        let name = item.key
        
        let alertController = UIAlertController(title: name, message: "Weet u zeker dat u deze coupon wilt inwisselen?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Annuleer", style: .cancel) { (action) in
        }
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let redeemedCouponsRef = FIRDatabase.database().reference(withPath: "coupons").child(name)
            redeemedCouponsRef.removeValue()
            self.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
        }
    }
}
