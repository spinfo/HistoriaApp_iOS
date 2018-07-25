
import Foundation

import MapKit

// A simple wrapper of the libraries' annotation class responsible for indicating a place on the map
class PlaceOnMapAnnotation : MKPointAnnotation {

    let placeOnMap: PlaceOnMap

    init(_ placeOnMap: PlaceOnMap) {
        self.placeOnMap = placeOnMap

        super.init()

        self.coordinate = placeOnMap.coordinate

        // this needs to be set to a non-empty string for mapkit to show any annotation
        self.title = "dummy-title"
    }

    public func getOrCreateAnnotationView(reuseFrom mapView: MKMapView) -> MKAnnotationView {
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId())
        if (view == nil) {
            view = createAnnotationView()
        }
        view!.annotation = self
        return view!
    }

    // Remove the title that was only needed for mapkit ro accept that this view can show
    // an annotation
    public func removeDummyTitle() {
        self.title = ""
    }

    private func createAnnotationView() -> MKAnnotationView {
        let view = MKAnnotationView(annotation: self, reuseIdentifier: reuseId())
        view.image = annotationImage()
        let imgSize = view.image!.size
        view.centerOffset = CGPoint(x: 0, y: (imgSize.height / 2) * -1)
        view.canShowCallout = true
        return view
    }

    private func reuseId() -> String {
        if (self.placeOnMap.hasTourBeginMapstop) {
            return "tour-begin-annotation"
        } else {
            return "normal-annotation"
        }
    }

    private func annotationImage() -> UIImage {
        if (self.placeOnMap.hasTourBeginMapstop) {
            return #imageLiteral(resourceName: "MarkerIconRed")
        } else {
            return #imageLiteral(resourceName: "MarkerIconBlue")
        }
    }

}
