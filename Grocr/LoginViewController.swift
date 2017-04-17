//
//  LoginViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 26-02-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let logInToList = "LoginToList"
    let ref = FIRDatabase.database().reference()
    let adminRef = FIRDatabase.database().reference(withPath: "admins")
    var admin: Admin!
    
    fileprivate var dataSource: PickerViewDataSource!
    
    var wasteLocations = [NearestWasteLocation]()
    let locationsPickerView = UIPickerView()
    var alert = UIAlertController()
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    // MARK: Properties
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
        self.wasteLocations = [.amsterdamsePoort, .hBuurt, .holendrecht, .venserpolder]
        self.dataSource = PickerViewDataSource(wasteLocations: self.wasteLocations)
        self.locationsPickerView.dataSource = self.dataSource
        self.locationsPickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textFieldLoginEmail.text = ""
        self.textFieldLoginPassword.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        
        //self.keychainItemWrapper["email"] = textFieldLoginEmail.text as AnyObject?
        //self.keychainItemWrapper["password"] = textFieldLoginPassword.text as AnyObject?
        
        if let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("Error loggin user in: \(error?.localizedDescription)")
                    return
                }
                if user != nil {
                    self.adminRef.queryOrdered(byChild: "email").queryEqual(toValue: self.textFieldLoginEmail.text).observe(.childAdded, with: { (snapShot) in
                        if snapShot.exists() {
                            self.admin = Admin(snapshot: snapShot)
                            self.performSegue(withIdentifier: self.logInToList, sender: nil)
                            print("login succesful")
                            print(self.admin)
                        }
                        else {
                            self.showAlertWith(title: "Fout", message: "Met het ingevoerde email adres: \(self.textFieldLoginEmail.text!) heeft u geen toegang)")
                        }
                    })
                    
                }
                
            })
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        self.alert = UIAlertController(title: "Registreer",
                                      message: "Maak een account aan",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Opslaan",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                                        
                                        let firstNameField = self.alert.textFields![0]
                                        let lastNameField = self.alert.textFields![1]
                                        let locationField = self.alert.textFields![2]
                                        let emailField = self.alert.textFields![3]
                                        let passwordField = self.alert.textFields![4]
                                        
                                        for textField in self.alert.textFields! {
                                            guard textField.text != "" else {
                                                self.showAlertWith(title: " \(textField.placeholder!) is niet ingevuld", message: "Zorg ervoor dat alle velden ingevuld zijn.")
                                                return
                                            }
                                        }
                                        
                                        if let email = emailField.text, let password = passwordField.text {
                                            
                                            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                                                if error != nil {
                                                    print("Error signing user in: \(error?.localizedDescription)")
                                                    return
                                                }
                                                else {
                                                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                                                        if error != nil {
                                                            print("Error loggin user in: \(error?.localizedDescription)")
                                                            return
                                                        }
                                                        else {
                                                            let newAdmin = Admin(firstName: firstNameField.text!, lastName: lastNameField.text!, email: emailField.text!, location: locationField.text!)
                                                            
                                                            let ref = self.adminRef.child(firstNameField.text!.lowercased())
                                                            ref.setValue(newAdmin.toAnyObject())
                                                            
                                                            self.performSegue(withIdentifier: self.logInToList, sender: nil)
                                                            print("login succesful")
                                                        }
                                                        
                                                    })
                                                    
                                                }
                                            })
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Annuleer",
                                         style: .default) { (action: UIAlertAction!) -> Void in
        }
        
        self.alert.addTextField { (firstNameField) in
            firstNameField.placeholder = "Voornaam"
            firstNameField.autocapitalizationType = .words
        }
        
        self.alert.addTextField { (lastNameField) in
            lastNameField.placeholder = "Achternaam"
            lastNameField.autocapitalizationType = .words
        }
        
        self.alert.addTextField { (locationField) in
            locationField.placeholder = "Selecteer uw locatie"
            locationField.inputView = self.locationsPickerView
        }
        
        self.alert.addTextField { (emailField) in
            emailField.placeholder = "Email"
            emailField.keyboardType = .emailAddress
        }
        
        self.alert.addTextField { (passwordField) in
            passwordField.placeholder = "Wachtwoord"
            passwordField.isSecureTextEntry = true
        }
        
        self.alert.addAction(saveAction)
        self.alert.addAction(cancelAction)
        
        present(self.alert,
                animated: true,
                completion: nil)
    }
    
    func keyboardWillHide(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    func keyboardWillShow(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        print(self.view.frame.origin.y)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.logInToList {
            if let navigationController = segue.destination as? UINavigationController, let listVC = navigationController.viewControllers.first as? GroceryListTableViewController {
            listVC.admin = self.admin
            }
        }
    }
}

// MARK: - PickerView delegate methods
extension LoginViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return wasteLocations[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.alert.textFields?[2].text = wasteLocations[row].rawValue
    }
}

