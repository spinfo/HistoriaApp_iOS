
import Foundation

import XCGLogger
import MapKit

class PlaceOnMap {

    // the mapstops on the map located at this place
    var mapstopsOnMap: [MapstopOnMap]

    // if one of the mapstops at the place is the beginning of tour
    var hasTourBeginMapstop: Bool

    // The place that this is wrapping
    var place: Place

    var coordinate: CLLocationCoordinate2D {
        return place.coordinate
    }

    init(_ place: Place) {
        self.place = place
        self.mapstopsOnMap = Array()
        self.hasTourBeginMapstop = false
    }

    func addMapstopOnMap(_ mapstopOnMap: MapstopOnMap) {
        self.mapstopsOnMap.append(mapstopOnMap)

        if(mapstopOnMap.isFirstInTour) {
            self.hasTourBeginMapstop = true
        }
    }
    
}
