//
//  MapPopupController.swift
//  HistoriaApp
//
//  Created by David on 06.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import UIKit
import SpeedLog

protocol MapPopupDelegate {
    func requestedPopupClose(sender: MapPopupController)
}

class MapPopupController : UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!

    @IBOutlet weak var containerView: UIView!

    public var delegate: MapPopupDelegate?

    override func viewDidLoad() {
        self.closeButton.action = #selector(self.userRequestedRemoval(sender:))
    }

    public func setPopup(byController otherViewC: UIViewController) {

        self.addChildViewController(otherViewC)
        self.containerView.addSubview(otherViewC.view!)
        otherViewC.view.translatesAutoresizingMaskIntoConstraints = false

        for direction in [NSLayoutAttribute.top, NSLayoutAttribute.right, NSLayoutAttribute.bottom, NSLayoutAttribute.left] {
            let constraint = NSLayoutConstraint(item: otherViewC.view, attribute: direction, relatedBy: .equal, toItem: self.containerView, attribute: direction, multiplier: 1.0, constant: 0.0)
            self.view.addConstraint(constraint)
        }
        otherViewC.didMove(toParentViewController: self)
    }

    @objc private func userRequestedRemoval(sender: UIBarButtonItem) {
        if self.delegate != nil {
            self.delegate?.requestedPopupClose(sender: self)
        } else {
            SpeedLog.print("WARN", "No delegate to send popup close action to.")
        }
    }

}
