//
//  TailWagger.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/27/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import UIKit

class TailWagger: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let image1 = UIImage.tailAnimationFrame1,
            let image2 = UIImage.tailAnimationFrame2,
            let image3 = UIImage.tailAnimationFrame3
        {
            animationImages = [image1, image2, image3, image2]
            animationDuration = 0.7
        }
    }
    
    func startWagging()
    {
        isHidden = false
        startAnimating()
    }
    
    func stopWagging()
    {
        isHidden = true
        stopAnimating()
    }
}
