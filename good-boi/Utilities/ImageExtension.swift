//
//  ImageExtension.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 1/1/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    static var logo: UIImage?
    {
        return UIImage(named: "logo")
    }
    
    static var tailAnimationFrame1: UIImage?
    {
        return UIImage(named: "tail_wag_1_of_3")
    }
    
    static var tailAnimationFrame2: UIImage?
    {
        return UIImage(named: "tail_wag_2_of_3")
    }
    
    static var tailAnimationFrame3: UIImage?
    {
        return UIImage(named: "tail_wag_3_of_3")
    }
    
    static var dogDetectedImage: UIImage?
    {
        return UIImage(named: "good_boi_detected")
    }
    
    static var yellowBackground: UIImage?
    {
        return UIImage(named: "background")
    }
}
