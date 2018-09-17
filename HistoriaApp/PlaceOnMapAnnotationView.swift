
import Foundation
import MapKit

class PlaceOnMapAnnotationView : MKAnnotationView {

    var mapstopView: MapstopOnMapCalloutDetailView!

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
        detailCalloutAccessoryView = self.mapstopView
    }

    public func updateContent(with mapstopOnMap: MapstopOnMap) {
        self.mapstopView.updateContentForImmediateDisplay(using: mapstopOnMap)
    }
}

class PlaceOnMapWithTourBeginAnnotationView : PlaceOnMapAnnotationView {

    override func annotationImage() -> UIImage {
        return #imageLiteral(resourceName: "MarkerIconRed")
    }

}

