//
//  Extensions.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 13-04-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

// Shows an alert with title, message and an ok action.
extension UIViewController {
    
    func showAlertWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWith(title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

// Ads aborder to a view.
extension UIView {
    func addBorderWith(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}
