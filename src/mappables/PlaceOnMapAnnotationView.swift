
import Foundation
import MapKit

class PlaceOnMapAnnotationView : MKAnnotationView, MapstopSelectionDelegate {

    var mapstopView: MapstopOnMapCalloutDetailView!

    var mapstopSelectionDelegate: MapstopSelectionDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        self.setupCalloutView()
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setup()
        self.setupCalloutView()
    }

    private func setup() {
        image = annotationImage()
        centerOffset = CGPoint(x: 0, y: (image!.size.height / 2) * -1)
        canShowCallout = true
    }

    func annotationImage() -> UIImage {
        return #imageLiteral(resourceName: "MarkerIconBlue")
    }

    private func setupCalloutView() {
        self.mapstopView = MapstopOnMapCalloutDetailView.instanceFromNib()
        self.mapstopView.mapstopSelectionDelegate = self
        detailCalloutAccessoryView = self.mapstopView
    }

    func updateContent(with mapstopOnMap: MapstopOnMap) {
        mapstopView.updateContentForImmediateDisplay(using: mapstopOnMap)
    }

    func mapstopSelected(_ mapstop: Mapstop) {
        mapstopSelectionDelegate?.mapstopSelected(mapstop)
    }
}

class PlaceOnMapWithTourBeginAnnotationView : PlaceOnMapAnnotationView {

    override func annotationImage() -> UIImage {
        return #imageLiteral(resourceName: "MarkerIconRed")
    }

}

class PlaceOnMapWithIndoorTourAnnotationView : PlaceOnMapAnnotationView {

    override func annotationImage() -> UIImage {
        return #imageLiteral(resourceName: "MarkerIconBlack")
    }
}

