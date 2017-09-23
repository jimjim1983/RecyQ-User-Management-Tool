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
import FirebaseAuth

class GroceryListTableViewController: UITableViewController {
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: Constants
    let ListToUsers = "ListToUsers"
    let ref = FIRDatabase.database().reference(withPath: "clients")
    let usersRef = FIRDatabase.database().reference(withPath: "online")
    
    // MARK: Properties
    var searchActive : Bool = false
    var items = [GroceryItem]()
    var filteredItems = [GroceryItem]()
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    var admin: Admin!
    
    fileprivate var dataSource: PickerViewDataSource!
    var wasteLocations = [NearestWasteLocation]()
    let locationsPickerView = UIPickerView()
    var alert = UIAlertController()
    var receivedBags = false
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetSearchBar()
        fetchUsersFromFirebase()
    }
    
    func setupViews() {
        if self.admin.firstName == "Test" || self.admin.firstName == "Richard" || self.admin.firstName == "Jacintha" {
            self.composeButton.isEnabled = true
        }
        self.wasteLocations = [.amsterdamsePoort, .hBuurt, .holendrecht, .venserpolder]
        self.dataSource = PickerViewDataSource(wasteLocations: self.wasteLocations)
        self.searchBar.delegate = self
        self.locationsPickerView.dataSource = self.dataSource
        self.locationsPickerView.delegate = self
    }
    
    func fetchUsersFromFirebase() {
        ref.queryOrdered(byChild: "name").observe(.value, with: { snapshot in
            var newItems = [GroceryItem]()
            for item in (snapshot.children) {
                let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(groceryItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    func resetSearchBar() {
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
        self.searchActive = false
    }
    
    // MARK: Compose action.

    @IBAction func composeButtonTapped(_ sender: Any) {
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {

        self.alert = UIAlertController(title: "Registreer",
                                      message: "Voer alle gegevens in.",
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
                                        
                                        let yesNoAlert = UIAlertController(title: "RecyQ tassen", message: "Selecteer of de nieuwe gebruiker tassen meekrijgt", preferredStyle: .alert)
                                        
                                        let yesAction = UIAlertAction(title: "Ja", style: .default, handler: { (yesAction) in
                                            self.receivedBags = true
                                            
                                            let groceryItem = GroceryItem(dateCreated: self.dateFormatter.string(from: Date()) , name: firstNameTextField.text!.lowercased(), lastName: lastNameTextField.text!, address: addressTextField.text!, zipCode: zipCodeTextField.text!, city: cityTextField.text!, phoneNumber: phoneTextField.text!, addedByUser: emailTextField.text!, nearestWasteLocation: NearestWasteLocation(rawValue: locationTextField.text!)!.rawValue, registeredVia: locationTextField.text, didReceiveRecyQBags: self.receivedBags, completed: false, amountOfPlastic: 0, amountOfPaper: 0, amountOfTextile: 0, amountOfEWaste: 0, amountOfBioWaste: 0, amountOfGlass: 0, wasteDepositInfo: nil, uid: uuid, spentCoins: 0 )
                                            let groceryItemRef = self.ref.child(firstNameTextField.text!.lowercased())
                                            groceryItemRef.setValue(groceryItem.toAnyObject())
                                            self.showAlertWith(title: "Bedankt!", message: "De nieuwe gebruiker: \(groceryItem.name.capitalized) \(groceryItem.lastName!) is toegevoegd")
                                        })
                                        
                                        let noAction = UIAlertAction(title: "Nee", style: .destructive, handler: { (noAction) in
                                            self.receivedBags = false
                                            
                                            let groceryItem = GroceryItem(dateCreated: self.dateFormatter.string(from: Date()) , name: firstNameTextField.text!.lowercased(), lastName: lastNameTextField.text!, address: addressTextField.text!, zipCode: zipCodeTextField.text!, city: cityTextField.text!, phoneNumber: phoneTextField.text!, addedByUser: emailTextField.text!, nearestWasteLocation: NearestWasteLocation(rawValue: locationTextField.text!)!.rawValue, registeredVia: locationTextField.text, didReceiveRecyQBags: self.receivedBags, completed: false, amountOfPlastic: 0, amountOfPaper: 0, amountOfTextile: 0, amountOfEWaste: 0, amountOfBioWaste: 0, amountOfGlass: 0, wasteDepositInfo: nil, uid: uuid, spentCoins: 0 )
                                            let groceryItemRef = self.ref.child(firstNameTextField.text!.lowercased())
                                            groceryItemRef.setValue(groceryItem.toAnyObject())
                                            self.showAlertWith(title: "Bedankt!", message: "De nieuwe gebruiker: \(groceryItem.name.capitalized) \(groceryItem.lastName!) is toegevoegd")
                                        })
                                        
                                        yesNoAlert.addAction(yesAction)
                                        yesNoAlert.addAction(noAction)
                                        self.present(yesNoAlert, animated: true, completion: nil)
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
    @IBAction func logOutButtonTapped(_ sender: Any) {
        
        // Log out from firebase
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            return
        }
    }
}

//MARK: - Search bar delegate methods.
extension GroceryListTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActive = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredItems = self.items.filter({ (item) -> Bool in
            if let lastName = item.lastName {
                let fullName = item.name + lastName
                return fullName.lowercased().range(of: searchText.lowercased()) != nil
            }
            return false
        })
        if searchText != "" {
            self.searchActive = true
            tableView.reloadData()
        }
        else {
            self.searchActive =  false
            tableView.reloadData()
        }
    }
}

// MARK: UITableView delegate source methods
extension GroceryListTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Only Richard is allowed to delete users.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if self.admin.firstName == "Richard" {
                let groceryItem = items[indexPath.row]
                groceryItem.ref?.removeValue()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        let chartsVC = self.storyboard?.instantiateViewController(withIdentifier: "chartsVC") as! ChartsViewController
        let groceryItem: GroceryItem!
        if self.searchActive {
            groceryItem = self.filteredItems[indexPath.row]
        }
        else {
            groceryItem = self.items[indexPath.row]
        }
        let wasteAmounts: [Double] = [groceryItem.amountOfPlastic, groceryItem.amountOfPaper, groceryItem.amountOfTextile, groceryItem.amountOfGlass ?? 0, groceryItem.amountOfBioWaste, groceryItem.amountOfEWaste]
        chartsVC.admin = self.admin
        chartsVC.amounts = wasteAmounts
        chartsVC.groceryItem = groceryItem
        
        self.navigationController?.pushViewController(chartsVC, animated: true)
    }
}

// MARK: UITableView data source methods
extension GroceryListTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return self.filteredItems.count
        }
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem: GroceryItem!
        if self.searchActive {
            groceryItem = self.filteredItems[indexPath.row]
        }
        else {
            groceryItem = self.items[indexPath.row]
        }
        let wasteTotal = Double(groceryItem.amountOfBioWaste) + Double(groceryItem.amountOfEWaste) +  Double(groceryItem.amountOfPaper) + Double(groceryItem.amountOfPlastic) + Double(groceryItem.amountOfTextile)
        
        if groceryItem.lastName?.capitalized != nil {
            cell.textLabel?.text = (groceryItem.name.capitalized) + " " + (groceryItem.lastName!.capitalized)
        }
        else {
            cell.textLabel?.text = groceryItem.name.capitalized
        }
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
        return cell
    }
}

// MARK: - PickerView delegate methods
extension GroceryListTableViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return wasteLocations[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.alert.textFields?[7].text = wasteLocations[row].rawValue
        self.view.endEditing(true)
    }
}


//MARK: Textfield delegate methods.
extension GroceryListTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.alert.textFields?[8] {
            let yesNoAlert = UIAlertController(title: "RecyQ tassen", message: "Selecteer of de nieuwe gebruiker tassen meekrijgt", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Ja", style: .default, handler: { (yesAction) in
                textField.text = "Ja"
            })
            
            let noAction = UIAlertAction(title: "Nee", style: .destructive, handler: { (noAction) in
                textField.text = "Nee"
            })
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            present(yesNoAlert, animated: true, completion: nil)
            print("DETECTED TEXTFIELD")
        }
    }
}

