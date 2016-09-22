//
//  PriceTextDelegate.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

class PriceTextDelegate: NSObject, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = textField.text! + string
        
        let array = Array(newString.characters)
        var pointCount = 0 //-count the decimal separator
        var unitsCount = 0 //-count units
        var decimalCount = 0 //-count decimals
        
        for character in array { //-counting loop
            if character == "." {
                pointCount += 1
            } else {
                if pointCount == 0 {
                    unitsCount += 1
                } else {
                    decimalCount += 1
                }
            }
        }
        if unitsCount > 5 { return false } //-units maximum : here 2 digits
        if decimalCount > 2 { return false } //-decimal maximum
        switch string {
        case "0","1","2","3","4","5","6","7","8","9": //-allowed characters
            return true
        case ".": //-block to one decimal separator to get valid decimal number
            if pointCount > 1 {
                return false
            } else {
                return true
            }
        default: //-manage delete key
            let array = Array(string.characters)
            if array.count == 0 {
                return true
            }
            unitsCount -= 1
            return false
        }
    }

    
    //-Ask the delegate if the RETURN key should be processed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    
}

