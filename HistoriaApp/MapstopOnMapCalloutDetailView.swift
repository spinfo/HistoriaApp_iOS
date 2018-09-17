
import Foundation
import UIKit

class MapstopOnMapCalloutDetailView : UIView {

    static let nibName = "MapstopOnMapCalloutDetailView"
    var view: UIView!

    @IBOutlet weak var tourName: UILabel!

    @IBOutlet weak var mapstopName: UILabel!

    @IBOutlet weak var mapstopDescription: UILabel!

    @IBOutlet weak var mainStack: UIStackView!

    var mapstopOnMap: MapstopOnMap!

    var mapstopSelectionDelegate: MapstopSelectionDelegate?

    class func instanceFromNib() -> MapstopOnMapCalloutDetailView {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MapstopOnMapCalloutDetailView
    }

    // this needs to be provided in order to render this detail view appropriately inside
    // the Mapkit callout view
    override var intrinsicContentSize: CGSize {
        get {
            return mainStack.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        }
    }

    public func updateContentForImmediateDisplay(using mapstopOnMap: MapstopOnMap) {
        updateContent(using: mapstopOnMap)
        prepareForDisplay()
    }

    private func updateContent(using mapstopOnMap: MapstopOnMap) {
        self.mapstopOnMap = mapstopOnMap

        tourName.text = mapstopOnMap.tourTitle
        mapstopDescription.text = mapstopOnMap.subtitle
    }

    private func prepareForDisplay() {
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }

    @IBAction func tapped(_ sender: Any) {
        if (mapstopSelectionDelegate != nil) {
            mapstopSelectionDelegate?.mapstopSelected(mapstopOnMap.mapstop)
        }
    }

}
