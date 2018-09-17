
import Foundation

import MapKit

// A simple wrapper of the libraries' annotation class responsible for indicating a place on the map
class PlaceOnMapAnnotation : MKPointAnnotation {

    let placeOnMap: PlaceOnMap

    init(_ placeOnMap: PlaceOnMap) {
        self.placeOnMap = placeOnMap

        super.init()

        self.coordinate = placeOnMap.coordinate
    }

    public func setupForCurrentMapstop() -> MapstopOnMap {
        return setupContent(for: placeOnMap.currentMapstopOnMap())
    }

    public func setupForNextMapstop() -> MapstopOnMap {
        return setupContent(for: placeOnMap.nextMapstopOnMap())
    }

    private func setupContent(for mapstopOnMap: MapstopOnMap) -> MapstopOnMap {
        self.title = mapstopOnMap.title
        return mapstopOnMap
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
