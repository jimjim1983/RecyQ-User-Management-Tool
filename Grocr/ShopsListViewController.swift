//
//  ShopsListViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 08-09-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class ShopsListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let shopsRef = FIRDatabase.database().reference(withPath: "Shops")
    var shops = [Shop]()
    //var shopItems = [ShopItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        title = "Winkeliers"
        // Do any additional setup after loading the view.
        
        self.shopsRef.observe(.value, with: { snapshot in
            self.shops.removeAll()
            for childSnap in snapshot.children.allObjects {
                let shopSnap = childSnap as! FIRDataSnapshot
                let shopName = shopSnap.key
                var shopItems = [ShopItem]()
                for shopItem in shopSnap.children.allObjects {
                    let item = shopItem as! FIRDataSnapshot
                    //print("SHOPITEMKEY: \(item.key)")
                    let shopItem = ShopItem(snapShot: item)
                    shopItems.append(shopItem)
                    //self.shopItems.append(shopItem)
                }
                let shop = Shop(shopName: shopName, shopItems: shopItems)
                self.shops.append(shop)
                //print("SHOP: \(shop.key)")
            }
            self.tableView.reloadData()
        })
    }
    
    func deleteFromFirebase(shop: Shop) {
        self.shopsRef.child(shop.shopName).removeValue()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showShopItems" {
                let shopItemsVC = segue.destination as! ShopItemsListViewController
                shopItemsVC.shops = self.shops
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let shop = self.shops[indexPath.row]
                    shopItemsVC.shopName = shop.shopName
                }
            } else if identifier == "AddShop" {
                let addShopVC = segue.destination as! AddShopViewController
                addShopVC.shops = self.shops
            }
        }
    }
}

extension ShopsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ShopsCell", for: indexPath)
        let shop = self.shops[indexPath.row]
        cell.textLabel?.text = shop.shopName
        cell.detailTextLabel?.text = "Validatie code: \(shop.shopItems[0].validationCode)"
        return cell
    }
}

extension ShopsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let shop = self.shops[indexPath.row]
            deleteFromFirebase(shop: shop)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Verwijder"
    }
}
