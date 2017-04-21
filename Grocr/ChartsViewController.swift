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

    @IBOutlet var barChartView: BarChartView!
    
    var admin: Admin!
    var groceryItem: GroceryItem!
    var wasteArray: [String]!
    var amounts: [Double]!
    var updatedAmounts :[Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews() {
        
        if groceryItem.lastName != nil {
            self.title = groceryItem.name.capitalized + " " + (groceryItem.lastName?.capitalized)!
        }
        else {
            self.title = groceryItem.name.capitalized
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showGroceryDetailVC))
        self.navigationController?.navigationBar.backItem?.title = "Anything Else"
        
        self.barChartView.delegate = self
        self.barChartView.xAxis.valueFormatter = self
        self.wasteArray = ["Plastic", "Paper", "Textile", "BioWaste", "EWaste"]
        self.setChart(dataPoints: self.wasteArray, values: amounts)
    }
    
    func showGroceryDetailVC() {
        let groceryDetailsVC = GroceryDetailsViewController(nibName: "GroceryDetailsViewController", bundle: nil)
        groceryDetailsVC.delegate = self
        groceryDetailsVC.admin = self.admin
        groceryDetailsVC.groceryItem = self.groceryItem
        self.navigationController?.pushViewController(groceryDetailsVC, animated: true)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "There is no data for the chart available."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            print(dataPoints.count)
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            
            dataEntries.append(dataEntry)
            print(dataEntries.count)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Amounts")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let colors = [#colorLiteral(red: 0, green: 0.8078528643, blue: 0.427520901, alpha: 1), #colorLiteral(red: 0, green: 0.7605165839, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.8486332297, blue: 0.249439925, alpha: 1), #colorLiteral(red: 1, green: 0.4083568454, blue: 0.251519829, alpha: 1), #colorLiteral(red: 0.506552279, green: 0.5065647364, blue: 0.5065580606, alpha: 1)]
        
        chartDataSet.colors = colors //ChartColorTemplates.colorful() //[UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        barChartView.xAxis.labelPosition = .bottom
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
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
    
    @IBAction func terugButtonTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}

// Extension to hold the required delegate method for updating the chart after waste is added.
extension ChartsViewController: GroceryDetailsViewControllerProtocol {
    func didFinishAddingWasteItems(sender: GroceryDetailsViewController) {
        self.groceryItem = sender.groceryItem
        self.updatedAmounts = [groceryItem.amountOfPlastic, groceryItem.amountOfPaper, groceryItem.amountOfTextile, groceryItem.amountOfBioWaste, groceryItem.amountOfEWaste]
        setChart(dataPoints: self.wasteArray, values: updatedAmounts!)
    }
}
