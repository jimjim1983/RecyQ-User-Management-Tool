//
//  ChartsViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 26-02-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Charts

class ChartsViewController: UIViewController, ChartViewDelegate, IAxisValueFormatter {

    @IBOutlet var dateCreatedLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var zipCodeAndCityLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var registeredVia: UILabel!
    @IBOutlet var didReceiveRecyQBags: UILabel!
    
    @IBOutlet var editStackView: UIStackView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var zipcodeTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    
    @IBOutlet var barChartView: BarChartView!
    
    var admin: Admin!
    var groceryItem: GroceryItem!
    var wasteArray: [String]!
    var amounts: [Double]!
    var updatedAmounts :[Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupViews()
        setUpChartView()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.groceryItem = nil
//    }
    
    private func setUpNavigationBar() {
        let detailViewBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showGroceryDetailVC))
        let changeUserDetailsItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editUserDetails))
        self.navigationItem.rightBarButtonItems = [detailViewBarItem] // Add the changeUserDetailsItem back.
        self.navigationController?.navigationBar.backItem?.title = "Anything Else"
    }
    
    private func setupViews() {
        self.editStackView.isHidden = true
        
        if groceryItem.lastName != nil {
            self.title = groceryItem.name.capitalized + " " + (groceryItem.lastName?.capitalized)!
            self.firstNameTextField.text = groceryItem.name.capitalized
            self.lastNameTextField.text = groceryItem.lastName?.capitalized
        }
        else {
            self.title = groceryItem.name.capitalized
        }
        
        if let dateCreated = groceryItem.dateCreated {
            self.dateCreatedLabel.text = dateCreated
        }
        
        if let registeredVia = groceryItem.registeredVia {
            self.registeredVia.text = registeredVia
        }
        
        if let address = groceryItem.address, let zipCode = groceryItem.zipCode, let city = groceryItem.city, let phone = groceryItem.phoneNumber {
            self.addressLabel.text = address
            self.zipCodeAndCityLabel.text = zipCode + " " + city
            self.phoneLabel.text = "Tel: \(phone)"
            self.emailLabel.text = groceryItem.addedByUser
            
            self.addressTextField.text = address
            self.zipcodeTextField.text = zipCode
            self.cityTextField.text = city
            self.phoneTextField.text = phone
            self.emailTextField.text = groceryItem.addedByUser
        }
        
        if let didReceiveRecyQBags = groceryItem.didReceiveRecyQBags {
            if didReceiveRecyQBags {
                self.didReceiveRecyQBags.text = "Ja"
            }
            else {
                self.didReceiveRecyQBags.text = "Nee"
            }
        }
    }
    
    private func setUpChartView() {
        self.barChartView.delegate = self
        self.barChartView.xAxis.valueFormatter = self
        self.wasteArray = ["Plastic", "Papier", "Textiel", "Glas", "BioWaste", "EWaste"]
        self.setChart(dataPoints: self.wasteArray, values: amounts)
    }
    
    func showGroceryDetailVC() {
        let groceryDetailsVC = GroceryDetailsViewController(nibName: "GroceryDetailsViewController", bundle: nil)
        groceryDetailsVC.delegate = self
        groceryDetailsVC.admin = self.admin
        groceryDetailsVC.groceryItem = self.groceryItem
        self.navigationController?.pushViewController(groceryDetailsVC, animated: true)
    }
    
    func editUserDetails() {
        self.editStackView.isHidden = !self.editStackView.isHidden
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        self.barChartView.noDataText = "There is no data for the chart available."
        self.barChartView.chartDescription?.text = ""

        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            print(dataPoints.count)
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            
            dataEntries.append(dataEntry)
            print(dataEntries.count)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Hoeveelheden in KG")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let colors = [#colorLiteral(red: 1, green: 0.4196078431, blue: 0.0431372549, alpha: 1), #colorLiteral(red: 0, green: 0.4392156863, blue: 0.8039215686, alpha: 1), #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 1, green: 0.7764705882, blue: 0.1529411765, alpha: 1), #colorLiteral(red: 0.2549019608, green: 0.5294117647, blue: 0.2431372549, alpha: 1), #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.4117647059, alpha: 1)]
        
        chartDataSet.colors = colors //ChartColorTemplates.colorful() //[UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        barChartView.xAxis.labelPosition = .bottom
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1
        barChartView.leftAxis.axisMinimum = 0.0
        //        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
        let ll = ChartLimitLine(limit: 10.0, label: "Target")
        barChartView.rightAxis.addLimitLine(ll)
    }
    
    // Returns strings for Double values. We need this to show text in the xAxis of a chart.
    public func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String
    {
        return self.wasteArray[Int(value)]
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        print("\(entry.y) in \(stringForValue(entry.x, axis: nil))")
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        let saveButton = sender as! UIButton
        saveButton.isEnabled = false
        saveButton.backgroundColor = .lightGray
        saveEditedUserDetails()
    }
    
    func saveEditedUserDetails() {
        let ref = FIRDatabase.database().reference(withPath: "clients")
        let userToEditRef = ref.child(self.groceryItem.key)
        
        //userToEditRef.child("name").setValue(self.firstNameTextField.text)
        userToEditRef.observe(.value, with: { (snapshot) in
            print("SNAPSHOT = : \(snapshot)")
            

            let user = self.editUser()
            ref.child(user.uid).setValue(user.toAnyObject())
            self.groceryItem = user
           // userToEditRef.removeValue()
        })
        
    }
    
    func editUser() -> GroceryItem {
        var editedUser: GroceryItem!
        if let user = self.groceryItem {
            let firstName = self.firstNameTextField.text ?? user.name
            let lastName = self.lastNameTextField.text ?? user.lastName
            let address = self.addressTextField.text ?? user.address
            let zipCode = self.zipcodeTextField.text ?? user.zipCode
            let city = self.cityTextField.text ?? user.city
            let phoneNumber = self.phoneTextField.text ?? user.phoneNumber
            let email = self.emailTextField.text ?? user.addedByUser
            editedUser = GroceryItem(dateCreated: user.dateCreated, name: firstName, lastName: lastName ?? "", address: address ?? "", zipCode: zipCode ?? "", city: city ?? "", phoneNumber: phoneNumber ?? "", addedByUser: email, nearestWasteLocation: user.nearestWasteLocation ?? "", registeredVia: user.registeredVia ?? "", didReceiveRecyQBags: user.didReceiveRecyQBags ?? false, completed: user.completed, amountOfPlastic: user.amountOfPlastic, amountOfPaper: user.amountOfPaper, amountOfTextile: user.amountOfTextile, amountOfEWaste: user.amountOfEWaste, amountOfBioWaste: user.amountOfBioWaste, amountOfGlass: user.amountOfGlass ?? 0, wasteDepositInfo: user.wasteDepositInfo, uid: user.uid, spentCoins: user.spentCoins ?? 0)
        }
        return editedUser
    }
}

// Extension to hold the required delegate method for updating the chart after waste is added.
extension ChartsViewController: GroceryDetailsViewControllerProtocol {
    func didFinishAddingWasteItems(sender: GroceryDetailsViewController) {
        self.groceryItem = sender.groceryItem
        self.updatedAmounts = [groceryItem.amountOfPlastic, groceryItem.amountOfPaper, groceryItem.amountOfTextile, groceryItem.amountOfGlass ?? 0, groceryItem.amountOfBioWaste, groceryItem.amountOfEWaste]
        setChart(dataPoints: self.wasteArray, values: updatedAmounts!)
    }
}
