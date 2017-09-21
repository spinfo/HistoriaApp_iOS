//
//  TourShortInfoView.swift
//  HistoriaApp
//
//  Created by David on 21.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class TourShortInfoView: UIView {

    let nibName = "TourShortInfoView"
    var view: UIView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var tagsLabel: UILabel!

    @IBOutlet weak var infosLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        // instantiate from the nib file
        let nib = UINib(nibName: self.nibName, bundle: Bundle(for: type(of: self)))
        self.view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        // properly arrange for display
        // self.view.frame = self.bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = false

        for direction in [NSLayoutAttribute.right, NSLayoutAttribute.left] {
            let constraint = NSLayoutConstraint(item: self.view, attribute: direction, relatedBy: .equal, toItem: self, attribute: direction, multiplier: 1.0, constant: 0.0)
            self.addConstraint(constraint)
        }

        self.addSubview(view)
    }

    func setTour(with tour: Tour) {
        self.nameLabel.text = tour.name

        self.infosLabel.text = String(format: "%@, %d min., %.2f km (%@)",
                                 tour.type.representation,
                                 tour.duration,
                                 (Float(tour.walkLength) / Float(1000)),
                                 tour.accessibility)

        self.tagsLabel.text = String(format: "%@ - %@ - %@",
                                tour.tagWhat,
                                tour.tagWhen,
                                tour.tagWhere)
    }

}
