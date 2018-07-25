//
//  MapstopOnMapCalloutDetail.swift
//  HistoriaApp
//
//  Created by David on 24.07.18.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation
import UIKit

class PlaceOnMapCalloutDetailView : UIView {

    @IBOutlet weak var tourName: UILabel!

    @IBOutlet weak var mapstopName: UILabel!

    @IBOutlet weak var mapstopDescription: UILabel!

    @IBOutlet weak var mainStack: UIStackView!

    override var intrinsicContentSize: CGSize {
        get {
            return mainStack.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        }
    }

    public func setButtonValues(with mapstopOnMap: MapstopOnMap) {
        self.mapstopName.text = mapstopOnMap.title
        self.tourName.text = mapstopOnMap.tourTitle
        self.mapstopDescription.text = mapstopOnMap.subtitle
        self.invalidateIntrinsicContentSize()
    }

}
