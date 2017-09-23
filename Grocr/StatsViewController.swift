//
//  StatsViewController.swift
//  RecyQ User Management Tool
//
//  Created by Fouad Astitou on 17-09-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Charts
import MessageUI

class StatsViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var barChartView: BarChartView!

    var clientsRef = FIRDatabase.database().reference(withPath: "clients")
    var wasteArray = [String]()
    var totalPlastic = [Double]()
    var totalPaper = [Double]()
    var totalTextile = [Double]()
    var totalGlass = [Double]()
    var totalBio = [Double]()
    var totalEWaste = [Double]()

    var amounts = [Double]()
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        fetchTotalWasteAmountsFromFireBase()
        setUpChartView()
    }
    
    func setUpViews() {
        title = "Totaal ingeleverd afval"
        let rightBarButtonItem = UIBarButtonItem(title: "PDF", style: .plain, target: self, action: #selector(pdfButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.titleLabel.text = "Totaal ingeleverd afval"
        self.dateLabel.text = self.dateFormatter.string(from: Date())
    }
    
    func fetchTotalWasteAmountsFromFireBase() {
        self.clientsRef.queryOrdered(byChild: "amountOfBioWaste").observe(.value, with: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for item in snapshots {
                    guard let amountOfPlastic = (item.value as AnyObject).object(forKey: "amountOfPlastic") as? Double,
                        let amountOfBioWaste = (item.value as AnyObject).object(forKey: "amountOfBioWaste") as? Double,
                        let amountOfEWaste = (item.value as AnyObject).object(forKey: "amountOfEWaste") as? Double,
                        let amountOfPaper = (item.value as AnyObject).object(forKey: "amountOfPaper") as? Double,
                        let amountOfTextile = (item.value as AnyObject).object(forKey: "amountOfTextile") as? Double else {
                            return
                    }
                    let amountOfGlass = (item.value as AnyObject).object(forKey: "amountOfGlass") as? Double ?? 0
                    self.totalPlastic.append(amountOfPlastic)
                    self.totalPaper.append(amountOfPaper)
                    self.totalTextile.append(amountOfTextile)
                    self.totalGlass.append(amountOfGlass)
                    self.totalBio.append(amountOfBioWaste)
                    self.totalEWaste.append(amountOfEWaste)
                }
                self.amounts.append(self.totalPlastic.reduce(0.0, +))
                self.amounts.append(self.totalPaper.reduce(0.0, +))
                self.amounts.append(self.totalTextile.reduce(0.0, +))
                self.amounts.append(self.totalGlass.reduce(0.0, +))
                self.amounts.append(self.totalBio.reduce(0.0, +))
                self.amounts.append(self.totalEWaste.reduce(0.0, +))

                DispatchQueue.main.async {
                    self.setChart(dataPoints: self.wasteArray, values: self.amounts)
                }
            }
        })
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        self.barChartView.noDataText = "There is no data for the chart available."
        self.barChartView.chartDescription?.text = ""
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Hoeveelheden in KG")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let colors = [#colorLiteral(red: 1, green: 0.4196078431, blue: 0.0431372549, alpha: 1), #colorLiteral(red: 0, green: 0.4392156863, blue: 0.8039215686, alpha: 1), #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 1, green: 0.7764705882, blue: 0.1529411765, alpha: 1), #colorLiteral(red: 0.2549019608, green: 0.5294117647, blue: 0.2431372549, alpha: 1), #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.4117647059, alpha: 1)]
        
        chartDataSet.colors = colors
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1
        barChartView.leftAxis.axisMinimum = 0.0
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
        //let ll = ChartLimitLine(limit: 10.0, label: "Target")
        //barChartView.rightAxis.addLimitLine(ll)
    }
    
    func pdfButtonTapped() {
        viewToPDF(view: view, fileName: "Totaal ingelverd afval")
    }
    
    func viewToPDF(view: UIView, fileName: String) -> String {
        
        // Creates a mutable data object for updating with binary data, like a byte array
        let pdfData = NSMutableData()
        
        // Points the pdf converter to the mutable data object and to the UIView to be converted
        UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil)
        UIGraphicsBeginPDFPage()
        let pdfContext = UIGraphicsGetCurrentContext();
        
        // Draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
        self.view.layer.render(in: pdfContext!)
        
        // Remove PDF rendering context
        UIGraphicsEndPDFContext()
        
        // Retrieves the document directories from the iOS device
        let documentDirectories: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        
        let documentDirectory = documentDirectories.object(at: 0)
        let documentDirectoryFilename = (documentDirectory as! NSString).appendingPathComponent(fileName);
        
        // Instructs the mutable data object to write its context to a file on disk
        pdfData.write(toFile: "/Users/Supervisor/stats.pdf", atomically: true)
    
        print("This is the filename: \(documentDirectoryFilename)")
        sendEmailWithAttachement(fileName: fileName, attachement: pdfData as Data)
        
        return documentDirectoryFilename
    }
    
    func sendEmailWithAttachement(fileName: String, attachement: Data) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["recyq@outlook.com","f.astitou@gmail.com"])
        mailComposer.setSubject("PDF van Statistieken")
        mailComposer.addAttachmentData(attachement, mimeType: "application/pdf", fileName: fileName)
        self.present(mailComposer, animated: true, completion: nil)
    }
}

extension StatsViewController: ChartViewDelegate {
    func setUpChartView() {
        self.barChartView.delegate = self
        self.barChartView.xAxis.valueFormatter = self
        self.wasteArray = ["Plastic", "Papier", "Textiel", "Glas", "BioWaste", "EWaste"]
    }
}

extension StatsViewController :IAxisValueFormatter {
    
    // Returns strings for Double values. We need this to show text in the xAxis of a chart.
    public func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        return self.wasteArray[Int(value)]
    }
}

extension StatsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
