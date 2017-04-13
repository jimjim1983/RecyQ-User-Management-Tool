//
//  PickerViewDataSource.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 13-04-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class PickerViewDataSource: NSObject {
    let wasteLocations: [NearestWasteLocation]
    
    init(wasteLocations: [NearestWasteLocation]) {
        self.wasteLocations = wasteLocations
    }
}

// MARK: - PickerView datasource methods
extension PickerViewDataSource: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return wasteLocations.count
    }
}
