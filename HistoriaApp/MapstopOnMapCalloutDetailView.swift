//
//  MapstopOnMapCalloutDetail.swift
//  HistoriaApp
//
//  Created by David on 24.07.18.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation
import UIKit

class MapstopOnMapCalloutDetailView : UIView {

    @IBOutlet weak var tourName: UILabel!

    @IBOutlet weak var mapstopName: UILabel!

    @IBOutlet weak var mapstopDescription: UILabel!

    @IBOutlet weak var mainStack: UIStackView!

    var mapstopOnMap: MapstopOnMap!

    var mapstopSelectionDelegate: MapstopSelectionDelegate?

    // this needs to be provided in order to render this detail view appropriately inside
    // the Mapkit callout view
    override var intrinsicContentSize: CGSize {
        get {
            return mainStack.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        }
    }

    public func setMapstopOnMap(_ mapstopOnMap: MapstopOnMap) {
        self.mapstopOnMap = mapstopOnMap

        self.mapstopName.text = mapstopOnMap.title
        self.tourName.text = mapstopOnMap.tourTitle
        self.mapstopDescription.text = mapstopOnMap.subtitle

        // the view needs a new size calculated as the subviews changed content
        self.invalidateIntrinsicContentSize()
    }

    @IBAction func viewTapped(_ sender: Any) {
        if (self.mapstopSelectionDelegate != nil) {
            self.mapstopSelectionDelegate?.mapstopSelected(mapstopOnMap.mapstop)
        }
    }

}
