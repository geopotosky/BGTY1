//
//  RoundButton.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

//* - Create custom button
class RoundButton: UIButton {
    required init?(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        let borderColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        self.layer.cornerRadius = 20.0;
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = UIColor.white
        self.tintColor = borderColor
    }
}
