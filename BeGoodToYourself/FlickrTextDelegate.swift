//
//  FlickrTextDelegate.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

class FlickrTextDelegate: NSObject, UITextFieldDelegate {
    
    //-Ask the delegate if the textfield should change
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText: NSString = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        return true;
    }
    
    //-Let the delegate know that editing has begun
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //-Check to see if the initial value of the textfield is TOP. If it is, clear it.
        if textField.text == "Enter Text/Phrase" {
            textField.text = ""
        }
        
    }
    
    //-Ask the delegate if the RETURN key should be processed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    
}
