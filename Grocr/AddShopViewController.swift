//
//  AddShopViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 24-07-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

protocol UpdateShopItemsDelegate: class {
    func addShopItem(shopItem: ShopItem)
}

class AddShopViewController: UIViewController {
    @IBOutlet var shopNameTextField: UITextField!
    @IBOutlet var itemDescriptionTextField: UITextField!
    @IBOutlet var tokenAmountTextField: UITextField!
    @IBOutlet var detailDescriptionTextView: UITextView!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var shopNameLabel: UILabel!
    
    let shopsRef = FIRDatabase.database().reference(withPath: "Shops")
    let testRef = FIRDatabase.database().reference(withPath: "Tests")
    var shops = [Shop]()
    var shopName: String?
    var shopItem: ShopItem?
    var validationCode: Int?
    var isAddingItem = false
    
    //weak var updateShopItemsDelegate: UpdateShopItemsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if let shopItem = self.shopItem {
            showShopItemDetails(shopItem: shopItem)
        } else if isAddingItem {
            configureViewForAddingNewItem()
        }
    }
    
    func setupViews() {
        self.shopNameTextField.addBorderWith(width: 1, color: .lightGray)
        self.itemDescriptionTextField.addBorderWith(width: 1, color: .lightGray)
        self.tokenAmountTextField.addBorderWith(width: 1, color: .lightGray)
        self.detailDescriptionTextView.addBorderWith(width: 1, color: .lightGray)
        
        self.tokenAmountTextField.delegate = self
    }
    
    func showShopItemDetails(shopItem: ShopItem) {
        title = "Wijzig product"
        self.shopNameTextField.isHidden = true
        self.shopNameLabel.isHidden = false
        self.shopNameLabel.text = shopItem.shopName
        self.itemDescriptionTextField.text = shopItem.itemName
        self.detailDescriptionTextView.text = shopItem.detailDescription
        self.tokenAmountTextField.text = "\(shopItem.tokenAmount)"
        
        if let imageData = Data(base64Encoded: shopItem.imageString, options: .ignoreUnknownCharacters) {
            self.itemImageView.image = UIImage(data: imageData)
        }
        self.saveButton.title = "Wijzig"
    }
    
    func configureViewForAddingNewItem() {
        title = "Product toevoegen"
        self.shopNameTextField.isHidden = true
        self.shopNameLabel.isHidden = false
        self.shopNameLabel.text = self.shopName ?? "Winkel onbekend"
    }
    
    func addItemOrShop() {
        self.saveButton.isEnabled = false
        
        if !isAddingItem {
            guard self.shopNameTextField.text != "" else {
               self.showAlertWith(title: "Fout", message: "Alle velden dienen ingevuld te zijn, en een foto dient geselecteerd te zijn")
                return
            }
        }
       
        guard self.itemDescriptionTextField.text != "",
            self.tokenAmountTextField.text != "",
            self.detailDescriptionTextView.text != "",
            self.itemImageView.image != #imageLiteral(resourceName: "Camera-Icon") else {
                self.showAlertWith(title: "Fout", message: "Alle velden dienen ingevuld te zijn, en een foto dient geselecteerd te zijn")
                self.saveButton.isEnabled = true
                return
        }
        
        // Check if the user is adding an item first.
        if let name = self.isAddingItem ? self.shopNameLabel.text : self.shopNameTextField.text,
            let item = self.itemDescriptionTextField.text,
            let description = detailDescriptionTextView.text,
            let tokens = self.tokenAmountTextField.text {
            
            // Check if the shop already exists, than we assign the existing validation code.
            for shop in self.shops {
                if shop.shopName.lowercased() == name.lowercased() {
                    self.validationCode = shop.shopItems.first?.validationCode
                }
            }
            
            let newItem = ShopItem(key: "",shopName: name, validationCode: self.validationCode ?? randomNumberWith(digits: 6), itemName: item, detailDescription: description, tokenAmount: Int(tokens) ?? 0, imageString: imageToBase64String(image: self.itemImageView.image))
            let ref = self.shopsRef.child(name).childByAutoId()
            ref.setValue(newItem.toAnyObject(), withCompletionBlock: { (error, reference) in
                if error == nil {
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (okAction) in
//                        if let updateShopItemsDelegate = self.updateShopItemsDelegate {
//                            updateShopItemsDelegate.addShopItem(shopItem: newItem)
//                        }
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    self.showAlertWith(title: "Succes", message: "De winkel is succesvol toegevoegd.", actions: [okAction])
                }
                else {
                    self.showAlertWith(title: "Fout", message: "Er is iets mis gegaan: \(error?.localizedDescription)")
                }
            })
        }
    }
    
    func editShopItem() {
        guard self.itemDescriptionTextField.text != "",
            self.tokenAmountTextField.text != "",
            self.detailDescriptionTextView.text != "",
            self.itemImageView.image != #imageLiteral(resourceName: "Camera-Icon") else {
                self.showAlertWith(title: "Fout", message: "Alle velden dienen ingevuld te zijn, en een foto dient geselecteerd te zijn")
                self.saveButton.isEnabled = true
                return
        }
        
        if let itemName = self.itemDescriptionTextField.text,
            let description = detailDescriptionTextView.text,
            let tokens = self.tokenAmountTextField.text,
            let shopItem = self.shopItem,
            let key = shopItem.key {
            
            let updatedValues = ["itemName": itemName as AnyObject,
                                 "tokenAmount": Int(tokens) as AnyObject,
                                 "detailDescription": description as AnyObject,
                                 "imageString": imageToBase64String(image: self.itemImageView.image) as AnyObject]
            
            let shop = self.shopsRef.child(shopItem.shopName)
            shop.child(key).updateChildValues(updatedValues)
            
            if let navigationController = navigationController {
                navigationController.popViewController(animated: true)
            }
        }
    }
    
    /// Used to transform a UIImage into a Base64String to store it in Firebase.
    func imageToBase64String(image: UIImage?) -> String {
        var imageString = ""
        if let image = image {
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                imageString = data.base64EncodedString(options: .lineLength64Characters)
            }
        }
        return imageString
    }
    
    func randomNumberWith(digits:Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(Range(uncheckedBounds: (min, max)))
    }
    
    @IBAction func tapAction(_ sender: Any) {
        showMediaLibrary()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        let sender = sender as! UIBarButtonItem
        if sender.title == "Wijzig" {
            editShopItem()
            debugPrint("Wijzig")
        } else if sender.title == "Opslaan" {
            addItemOrShop()
        }
    }
}

// MARK: - UITetFieldDelegate functions.
extension AddShopViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.allowsOnlyNumbers(text: string)
    }
}

// MARK: UIImagePickerDelegate funtions.
extension AddShopViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showMediaLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.navigationBar.barTintColor = #colorLiteral(red: 0.1795298159, green: 0.8247315288, blue: 0.01185110956, alpha: 1)
        imagePicker.navigationBar.tintColor = .darkGray
        imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //let profileImage = image.fixOrientation()
            self.itemImageView.image = image
            //self.cameraIconImageView.isHidden = true
            //saveImage(image: profileImage, pathComponent: "ProfileImage")
        }
    }
}
