
import Foundation

import MapKit

// A simple wrapper of the libraries' annotation class responsible for indicating a place on the map
class PlaceOnMapAnnotation : MKPointAnnotation {

    let placeOnMap: PlaceOnMap

    init(_ placeOnMap: PlaceOnMap) {
        self.placeOnMap = placeOnMap

        super.init()

        self.coordinate = placeOnMap.coordinate

        setupDummyTitle()
    }

    public func removeDummyTitle() {
        if (iosVersionNeedsDummyTitle()) {
            self.title = nil
        }
    }

    public func setupDummyTitle() {
        if (iosVersionNeedsDummyTitle()) {
            // this needs to be set to a non-empty string for mapkit to show any annotation
            self.title = "dummy-title"
        }
    }

    private func iosVersionNeedsDummyTitle() -> Bool {
        let version = OperatingSystemVersion(majorVersion: 11, minorVersion: 0, patchVersion: 0)
        return !(ProcessInfo.processInfo.isOperatingSystemAtLeast(version))
    }

    public func getOrCreateAnnotationView(reuseFrom mapView: MKMapView) -> PlaceOnMapAnnotationView {
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId())
        if (view == nil) {
            view = createAnnotationView()
        }
        view!.annotation = self
        return view as! PlaceOnMapAnnotationView
    }

    private func reuseId() -> String {
        if (self.placeOnMap.hasTourBeginMapstop) {
            return String(describing: PlaceOnMapWithTourBeginAnnotationView.self)
        } else {
            return String(describing: PlaceOnMapAnnotationView.self)
        }
    }

    private func createAnnotationView() -> PlaceOnMapAnnotationView {
        if (self.placeOnMap.hasTourBeginMapstop) {
            return PlaceOnMapWithTourBeginAnnotationView(annotation: self, reuseIdentifier: reuseId())
        } else {
            return PlaceOnMapAnnotationView(annotation: self, reuseIdentifier: reuseId())
        }
    }

}
