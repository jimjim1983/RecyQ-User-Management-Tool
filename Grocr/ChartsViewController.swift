//
//  ChartsViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 26-02-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Charts

class ChartsViewController: UIViewController, IAxisValueFormatter {

    @IBOutlet var barChartView: BarChartView!
    
    var groceryItem: GroceryItem!
    
    var wasteArray: [String]!
    var amounts: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = groceryItem.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWaste))
        
        barChartView.xAxis.valueFormatter = self
        
        self.wasteArray = ["Plastic", "Paper", "Textile", "Iron", "BioWaste", "EWaste"]
        if let amounts = self.amounts {
            
            setChart(dataPoints: self.wasteArray, values: amounts)
        }
    }
    
    func addWaste() {
        let groceryDetailsVC = GroceryDetailsViewController(nibName: "GroceryDetailsViewController", bundle: nil)
        groceryDetailsVC.groceryItem = self.groceryItem
        self.navigationController?.pushViewController(groceryDetailsVC, animated: true)//(groceryDetailsVC, animated: true, completion: nil)
    }
    
    public func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String
    {
        return self.wasteArray[Int(value)]
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "There is no data for the chart available."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Amounts")
        
        //        let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let colors = [#colorLiteral(red: 0, green: 0.8078528643, blue: 0.427520901, alpha: 1), #colorLiteral(red: 0, green: 0.7605165839, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.8486332297, blue: 0.249439925, alpha: 1), #colorLiteral(red: 1, green: 0.4083568454, blue: 0.251519829, alpha: 1), #colorLiteral(red: 0.506552279, green: 0.5065647364, blue: 0.5065580606, alpha: 1), #colorLiteral(red: 0.9593952298, green: 0.9594177604, blue: 0.959405601, alpha: 1)]
        
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
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("\(entry.y) in \(entry.x)")
    }
    
    @IBAction func terugButtonTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
