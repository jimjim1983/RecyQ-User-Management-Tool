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

import UIKit

class GroceryListTableViewController: UITableViewController {
    
    // MARK: Constants
    let ListToUsers = "ListToUsers"
    let ref = FIRDatabase.database().reference(withPath: "clients")
    let usersRef = FIRDatabase.database().reference(withPath: "online")
    
    // MARK: Properties
    var items = [GroceryItem]()
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    fileprivate var dataSource: PickerViewDataSource!
    var wasteLocations = [NearestWasteLocation]()
    let locationsPickerView = UIPickerView()
    var alert = UIAlertController()

    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set up swipe to delete
        tableView.allowsMultipleSelectionDuringEditing = false
        
        self.wasteLocations = [.amsterdamsePoort, .hBuurt, .holendrecht, .venserpolder]
        self.dataSource = PickerViewDataSource(wasteLocations: self.wasteLocations)
        self.locationsPickerView.dataSource = self.dataSource
        self.locationsPickerView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ref.queryOrdered(byChild: "name").observe(.value, with: { snapshot in
            var newItems = [GroceryItem]()
            for item in (snapshot.children) {
                let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(groceryItem)
            }
            self.items = newItems
            self.tableView.reloadData()
            
            //Unauthorize in case of a crash caused by the deletion of the user on the back end
            //self.ref.unauth()
            
        })
        
//        FIRAuth.auth()!.addStateDidChangeListener({ (auth, firUser) in
//            if let firUser = firUser {
//                self.user = User(user: firUser)
//                let currentUserRef = self.usersRef.child(self.user.uid)
//                currentUserRef.setValue(self.user.email)
//                currentUserRef.onDisconnectRemoveValue()
//            }
//        })
        //        ref.observeAuthEvent { authData in
        //            if authData != nil {
        //                self.user = User(authData: authData!)
        //                let currentUserRef = self.usersRef?.child(byAppendingPath: self.user.uid)
        //                currentUserRef?.setValue(self.user.email)
        //                currentUserRef?.onDisconnectRemoveValue()
        //            }
        //        }
        usersRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            }
            else {
                self.userCountBarButtonItem?.title = "0"
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        let wasteTotal = Double(groceryItem.amountOfBioWaste) + Double(groceryItem.amountOfEWaste) +  Double(groceryItem.amountOfPaper) + Double(groceryItem.amountOfPlastic) + Double(groceryItem.amountOfTextile)
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.textColor = UIColor.darkGray
        
        if wasteTotal >= 1 {
            cell.detailTextLabel?.text = "Beginning user"
            
        }
        if wasteTotal == 0 {
            cell.detailTextLabel?.text = "New User"
            
        }
        if wasteTotal > 30 {
            cell.detailTextLabel?.text = "Frequent User"
            
        }
        if wasteTotal > 50 {
            cell.detailTextLabel?.text = "Loyal User"
            
        }
        if wasteTotal > 120 {
            cell.detailTextLabel?.text = "Top User"
            
        }
        if wasteTotal > 250 {
            cell.detailTextLabel?.text = "Super Awesome User"
            
        }
        
        // Determine whether the cell is checked
        // toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groceryItem = items[indexPath.row]
            groceryItem.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let groceryDetailVC = GroceryDetailsViewController()
        let chartsVC = self.storyboard?.instantiateViewController(withIdentifier: "chartsVC") as! ChartsViewController
        let groceryItems = items[indexPath.row]
        let wasteAmounts: [Double] = [groceryItems.amountOfPlastic, groceryItems.amountOfPaper, groceryItems.amountOfTextile, groceryItems.amountOfBioWaste, groceryItems.amountOfEWaste]
        chartsVC.amounts = wasteAmounts
        chartsVC.groceryItem = groceryItems
        //        groceryDetailVC.groceryItem = groceryItems
        //        let navigationController = UINavigationController(rootViewController: barChartVC)
        //        self.present(navigationController, animated: true, completion: nil)
        
        self.navigationController?.pushViewController(chartsVC, animated: true)
        
        //let cell = tableView.cellForRowAtIndexPath(indexPath)!
        //        var groceryItem = items[indexPath.row]
        //        groceryDetailVC.
        
        // let toggledCompletion = !groceryItem.completed
        //toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        //groceryItem.ref?.updateChildValues(["completed": toggledCompletion])
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        // Alert View for input
        
        // log out
        //            ref.unauth()
        //            let loginVC = LoginViewController()
        //            self.presentViewController(loginVC, animated: true, completion: nil)
        
        
        //            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //            appDelegate.window?.rootViewController = loginVC
        
        
        
        
        self.alert = UIAlertController(title: "Voer gebruikersnaam in",
                                      message: "van nieuwe gebruiker",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Opslaan",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                                        
                                        let firstNameTextField = self.alert.textFields![0]
                                        let lastNameTextField = self.alert.textFields![1]
                                        let addressTextField = self.alert.textFields![2]
                                        let zipCodeTextField = self.alert.textFields![3]
                                        let cityTextField = self.alert.textFields![4]
                                        let phoneTextField = self.alert.textFields![5]
                                        let emailTextField = self.alert.textFields![6]
                                        let locationTextField = self.alert.textFields![7]
                                        let uuid = UUID().uuidString
                                        
                                        for textField in self.alert.textFields! {
                                            guard textField.text != "" else {
                                                self.showAlertWith(title: " \(textField.placeholder!) is niet ingevuld", message: "Zorg ervoor dat alle velden ingevuld zijn.")
                                                return
                                            }
                                        }
                                        
                                        let groceryItem = GroceryItem(name: firstNameTextField.text!, lastName: lastNameTextField.text!, address: addressTextField.text!, zipCode: zipCodeTextField.text!, city: cityTextField.text!, phoneNumber: phoneTextField.text!, addedByUser: emailTextField.text!, nearestWasteLocation: NearestWasteLocation(rawValue: locationTextField.text!)!.rawValue, completed: false, amountOfPlastic: 0, amountOfPaper: 0, amountOfTextile: 0, amountOfEWaste: 0, amountOfBioWaste: 0, uid: uuid, spentCoins: 0 )
                                        let groceryItemRef = self.ref.child(firstNameTextField.text!.lowercased())
                                        groceryItemRef.setValue(groceryItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Annuleer",
                                         style: .default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (firstNameTextField) in
            firstNameTextField.placeholder = "Voornaam"
            firstNameTextField.autocapitalizationType = .words
        }
        alert.addTextField { (lastNameTextField)  in
            lastNameTextField.placeholder = "Achternaam"
            lastNameTextField.autocapitalizationType = .words
        }
        
        alert.addTextField { (addressTextField) in
            addressTextField.placeholder = "Adres en huisnummer"
            addressTextField.autocapitalizationType = .words
        }
        
        alert.addTextField { (zipCodeTextField) in
            zipCodeTextField.placeholder = "Postcode"
            zipCodeTextField.keyboardType = .numberPad
            zipCodeTextField.autocapitalizationType = .allCharacters
        }
        
        alert.addTextField { (cityTextField) in
            cityTextField.placeholder = "WoonPlaats"
            cityTextField.autocapitalizationType = .words
        }
        
        alert.addTextField { (phoneTextField) in
            phoneTextField.placeholder = "Telefoonnummer"
            phoneTextField.keyboardType = .numberPad
        }
        
        alert.addTextField { (emailTextField) in
            emailTextField.placeholder = "Email"
            emailTextField.keyboardType = .emailAddress
        }
        
        alert.addTextField { (locationTextField) in
            locationTextField.placeholder = "Selecteer een locatie"
            locationTextField.inputView = self.locationsPickerView
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert,
                animated: true,
                completion: nil)
    }
    
    func userCountButtonDidTouch() {
        performSegue(withIdentifier: ListToUsers, sender: nil)
    }
}

// MARK: - PickerView delegate methods
extension GroceryListTableViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return wasteLocations[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.alert.textFields?[7].text = wasteLocations[row].rawValue
    }
}
