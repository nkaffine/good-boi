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
    case dismiss, settings
}

class ErrorViewController: UIViewController {

    @IBOutlet private (set) var titleLabel: UILabel!
    @IBOutlet private (set) var detailLabel: UILabel!
    @IBOutlet private (set) var button: UIButton!
    
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
        }
        button.backgroundColor = .primaryPawBlue
        button.setTitleColor(.secondaryPawBlue, for: .normal)
        view.backgroundColor = .yellowBackground
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.secondaryPawBlue.cgColor
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
                        self?.dismiss(animated: true)
                    })
                }
        }
    }
}
