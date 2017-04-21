//
//  GroceryDetailsViewController.swift
//  Grocr
//
//  Created by Jim Petri on 11/04/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

protocol GroceryDetailsViewControllerProtocol: class {
    func didFinishAddingWasteItems(sender: GroceryDetailsViewController)
}

var couponName = String()

class GroceryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: GroceryDetailsViewControllerProtocol?
    var admin: Admin!
    
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
    
    lazy var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    
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
        if groceryItem.lastName != nil {
            emailLabel.text = (groceryItem.name.capitalized.characters.first?.description)! + ". " + (groceryItem.lastName?.capitalized)!
        }
        else {
            emailLabel.text = groceryItem.name.capitalized
        }
        
        //        if let emailLabelText = groceryItem.name {
        //            emailLabel.text = "\(emailLabelText)"
        //        }
        let amountOfPlastic = groceryItem.amountOfPlastic
        plasticLabel.text = "\(amountOfPlastic)"
        
        let amountOfPaper = groceryItem.amountOfPaper
        paperLabel.text = "\(amountOfPaper)"
        
        let amountOfTextile = groceryItem.amountOfTextile
        textileLabel.text = "\(amountOfTextile)"
        
        let amountOfEWaste = groceryItem.amountOfEWaste
        eWasteLabel.text = "\(amountOfEWaste)"
        
        let amountOfBioWaste = groceryItem.amountOfBioWaste
        bioWasteLabel.text = "\(amountOfBioWaste)"
        
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
        ref = FIRDatabase.database().reference(withPath: "clients").child(name)
        
        let amountOfPlastic = groceryItem.amountOfPlastic + ((plasticTextField.text)! as NSString).doubleValue
        ref.child("amountOfPlastic").setValue(amountOfPlastic)
        self.groceryItem.amountOfPlastic = amountOfPlastic
        
        let amountOfPaper = groceryItem.amountOfPaper + ((paperTextField.text)! as NSString).doubleValue
        ref.child("amountOfPaper").setValue(amountOfPaper)
        self.groceryItem.amountOfPaper = amountOfPaper
        
        let amountOfTextile = groceryItem.amountOfTextile + ((textileTextField.text)! as NSString).doubleValue
        ref.child( "amountOfTextile").setValue(amountOfTextile)
        self.groceryItem.amountOfTextile = amountOfTextile
        
        let amountOfEWaste = groceryItem.amountOfEWaste + ((eWasteTextField.text)! as NSString).doubleValue
        ref.child( "amountOfEWaste").setValue(amountOfEWaste)
        self.groceryItem.amountOfEWaste = amountOfEWaste
        
        let amountOfBioWaste = groceryItem.amountOfBioWaste + ((bioWasteTextField.text)! as NSString).doubleValue
        ref.child( "amountOfBioWaste").setValue(amountOfBioWaste)
        self.groceryItem.amountOfBioWaste = amountOfBioWaste
        
        let adminName = self.admin.firstName + " " + self.admin.lastName
        let wasteDepositInfo: [String: Any] = [
            "Admin": adminName,
            "Datum": self.dateFormatter.string(from: Date()),
            "Locatie": self.admin.location,
            "Plastic": ((plasticTextField.text)! as NSString).doubleValue,
            "Papier": ((paperTextField.text)! as NSString).doubleValue,
            "Textiel": ((textileTextField.text)! as NSString).doubleValue,
            "E-Waste": ((eWasteTextField.text)! as NSString).doubleValue,
            "Bio": ((bioWasteTextField.text)! as NSString).doubleValue]
        
        ref.child("wasteDepositInfo").childByAutoId().setValue(wasteDepositInfo)
        
        if let delegate = self.delegate {
            delegate.didFinishAddingWasteItems(sender: self)
            _ = self.navigationController?.popViewController(animated: true)
        }
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
