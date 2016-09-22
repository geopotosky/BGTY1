//
//  MGButton.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//


import Foundation
import UIKit

//* - Create custom button
class MGButton: UIButton {
    required init?(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        let borderColor = UIColor.clear
        let buttonColor = UIColor.clear
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1.0
        self.backgroundColor = buttonColor
        self.tintColor = borderColor
    }
}
