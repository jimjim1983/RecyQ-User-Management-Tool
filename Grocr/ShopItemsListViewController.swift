//
//  ShopItemsListViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 08-09-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class ShopItemsListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let shopsRef = FIRDatabase.database().reference(withPath: "Shops")
    var shopName: String?
    var shops = [Shop]()
    var shopItems = [ShopItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        title = self.shopItems.first?.shopName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let shopName = self.shopName {
            self.shopsRef.child(shopName).observe(.value, with: { snapshot in
                self.shopItems.removeAll()
                for item in snapshot.children {
                    let shopItem = ShopItem(snapShot: item as! FIRDataSnapshot)
                    self.shopItems.insert(shopItem, at: 0)
                }
                self.tableView.reloadData()
            })

        }
    }
    
    func deleteFromFirebase(item: ShopItem) {
        let shop = self.shopsRef.child(item.shopName)
        if let key = item.key {
            let shopItem = shop.child(key)
            shopItem.removeValue()
        }
    }
    
    func deleteFromShopItems(item: ShopItem, at index:Int) {
        self.shopItems.remove(at: index)
        if self.shopItems.count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "showShopItem" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let shopItem = self.shopItems[indexPath.row]
                let editShopItemVC = segue.destination as! AddShopViewController
                editShopItemVC.shops = self.shops
                editShopItemVC.shopItem = shopItem
            }
        } else if identifier == "AddShopItem" {
            let shopName = self.shopItems.first?.shopName
            let addShopItemVC = segue.destination as! AddShopViewController
            addShopItemVC.shops = self.shops
            addShopItemVC.shopName = shopName
            addShopItemVC.isAddingItem = true
            //addShopItemVC.updateShopItemsDelegate = self
        }
    }
}

extension ShopItemsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shopItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ShopItemsCell", for: indexPath)
        let shopItem = self.shopItems[indexPath.row]
        cell.textLabel?.text = shopItem.itemName //"Voeg een winkelier toe"
        cell.detailTextLabel?.text = shopItem.detailDescription
        return cell
    }
}

extension ShopItemsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let shopItem = self.shopItems[indexPath.row]
            deleteFromFirebase(item: shopItem)
            deleteFromShopItems(item: shopItem, at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

//extension ShopItemsListViewController: UpdateShopItemsDelegate {
//    func addShopItem(shopItem: ShopItem) {
//        self.shopItems.insert(shopItem, at: 0)
//        self.tableView.reloadData()
//    }
//}
