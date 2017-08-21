//
//  AddShopViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 24-07-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class AddShopViewController: UIViewController {
    @IBOutlet var shopNameTextField: UITextField!
    @IBOutlet var itemDescriptionTextField: UITextField!
    @IBOutlet var tokenAmountTextField: UITextField!
    @IBOutlet var detailDescriptionTextView: UITextView!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    let shopsRef = FIRDatabase.database().reference(withPath: "Shops")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.shopNameTextField.addBorderWith(width: 1, color: .lightGray)
        self.itemDescriptionTextField.addBorderWith(width: 1, color: .lightGray)
        self.tokenAmountTextField.addBorderWith(width: 1, color: .lightGray)
        self.detailDescriptionTextView.addBorderWith(width: 1, color: .lightGray)
        
        self.tokenAmountTextField.delegate = self
    }
    
    func addShop() {
        self.saveButton.isEnabled = false
        guard self.shopNameTextField.text != "",
            self.itemDescriptionTextField.text != "",
            self.tokenAmountTextField.text != "",
            self.detailDescriptionTextView.text != "",
            self.itemImageView.image != #imageLiteral(resourceName: "Camera-Icon") else {
                self.showAlertWith(title: "Fout", message: "Alle velden dienen ingevuld te zijn, en een foto dient geselecteerd te zijn")
                self.saveButton.isEnabled = true
                return
        }
        
        if let name = self.shopNameTextField.text, let item = self.itemDescriptionTextField.text, let description = detailDescriptionTextView.text, let tokens = self.tokenAmountTextField.text {
            let validationCode = randomNumberWith(digits: 6)
            let newShop = Shop(shopName: name, validationCode: validationCode, itemName: item, detailDescription: description, tokenAmount: Int(tokens) ?? 0, imageString: imageToBase64String(image: self.itemImageView.image))
            let ref = self.shopsRef.child(name).childByAutoId()
            ref.setValue(newShop.toAnyObject(), withCompletionBlock: { (error, reference) in
                if error == nil {
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (okAction) in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    self.showAlertWith(title: "Succes", message: "De winkel is succesvol toegevoegd.Validatie code: \(validationCode)", actions: [okAction])
                }
                else {
                    self.showAlertWith(title: "Fout", message: "Er is iets mis gegaan: \(error?.localizedDescription)")
                }
            })
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
        addShop()
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
