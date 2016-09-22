//
//  ActivitySquare.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright © 2016 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

//* - Create custom button
class ActivitySquare: UIButton {
    required init?(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        let borderColor = UIColor.clear
        let buttonColor = UIColor(red:0.0,green:0.51,blue:0.83,alpha:1.0)
        self.layer.cornerRadius = 12.0;
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = buttonColor
        self.tintColor = borderColor
    }
}
