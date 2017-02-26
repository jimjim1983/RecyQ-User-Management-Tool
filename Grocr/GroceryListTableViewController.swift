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
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set up swipe to delete
        tableView.allowsMultipleSelectionDuringEditing = false
        
        // User Count
        //        userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroceryListTableViewController.userCountButtonDidTouch))
        //        userCountBarButtonItem.tintColor = UIColor.whiteColor()
        //        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        //user = User(uid: "FakeId", email: "hungry@person.food")
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
        
        FIRAuth.auth()!.addStateDidChangeListener({ (auth, firUser) in
            if let firUser = firUser {
                self.user = User(user: firUser)
                let currentUserRef = self.usersRef.child(self.user.uid)
                currentUserRef.setValue(self.user.email)
                currentUserRef.onDisconnectRemoveValue()
            }
        })
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
        let wasteTotal = Double(groceryItem.amountOfBioWaste) + Double(groceryItem.amountOfEWaste) + Double(groceryItem.amountOfIron) + Double(groceryItem.amountOfPaper) + Double(groceryItem.amountOfPlastic) + Double(groceryItem.amountOfTextile)
        
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
        let wasteAmounts: [Double] = [groceryItems.amountOfPlastic, groceryItems.amountOfPaper, groceryItems.amountOfTextile, groceryItems.amountOfIron, groceryItems.amountOfBioWaste, groceryItems.amountOfEWaste]
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
        
        
        
        
        let alert = UIAlertController(title: "Voer gebruikersnaam in",
                                      message: "van nieuwe gebruiker",
                                      preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Opslaan",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                                        
                                        let textField = alert.textFields![0]
                                        let textField2 = alert.textFields![1]
                                        let uuid = UUID().uuidString
                                        let groceryItem = GroceryItem(name: textField.text!, addedByUser: textField2.text!, completed: false, amountOfPlastic: 0, amountOfPaper: 0, amountOfTextile: 0, amountOfEWaste: 0, amountOfBioWaste: 0, amountOfIron: 0, uid: uuid)
                                        let groceryItemRef = self.ref.child(textField.text!.lowercased())
                                        groceryItemRef.setValue(groceryItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Annuleer",
                                         style: .default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Voer gebruikersnaam in"
        }
        alert.addTextField {
            (textField2: UITextField!) -> Void in
            textField2.placeholder = "Voer e-mailadres in"
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
