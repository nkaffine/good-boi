//
//  ErrorViewController.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/27/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import UIKit

enum ErrorButtonAction
{
    case dismiss, settings, none
}

class ErrorViewController: UIViewController {

    @IBOutlet private (set) var titleLabel: UILabel!
    @IBOutlet private (set) var detailLabel: UILabel!
    @IBOutlet private (set) var button: UIButton!
    @IBOutlet private (set) var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet private (set) var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet private (set) var logo: UIImageView!
    
    var errorTitle: String?
    var detail: String?
    var action: ErrorButtonAction = .dismiss
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = errorTitle
        detailLabel.text = detail
        switch action
        {
            case .dismiss:
                button.setTitle("Dismiss", for: .normal)
            case .settings:
                button.setTitle("Settings", for: .normal)
            case .none:
                button.isHidden = true
                logo.isHidden = true
        }
        view.backgroundColor = UIColor.yellowBackground
        button.backgroundColor = UIColor.secondaryPawBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        if let yellowBackground = UIImage.yellowBackground
        {
            view.backgroundColor = UIColor(patternImage: yellowBackground)
        }
        logoHeightConstraint.constant = button.frame.height
        logoCenterConstraint.constant = button.frame.width / -2
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch action
        {
            case .dismiss:
                dismiss(animated: true)
            case .settings:
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else
                {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { [weak self] (success) in
                        if AVHandler.isAuthorized
                        {
                            self?.dismiss(animated: true)
                        }
                    })
                }
            case .none:
                break
        }
    }
}
