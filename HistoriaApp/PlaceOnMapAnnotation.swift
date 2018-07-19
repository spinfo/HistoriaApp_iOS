
import Foundation

import MapKit

// A simple wrapper a mapox annotation allowing for the connection from
// annotation to the mapstop and the place on map
class PlaceOnMapAnnotation : NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D

    let placeOnMap: PlaceOnMap

    var title: String?
    var subtitle: String?

    init(_ placeOnMap: PlaceOnMap) {
        self.coordinate = placeOnMap.coordinate
        self.placeOnMap = placeOnMap

        super.init()

        self.setTitleAndSubtitle(from: placeOnMap.mapstopsOnMap.first!)
    }

    private func setTitleAndSubtitle(from mapstopOnMap: MapstopOnMap) {
        self.title = mapstopOnMap.title
        self.subtitle = mapstopOnMap.subtitle
    }

}
