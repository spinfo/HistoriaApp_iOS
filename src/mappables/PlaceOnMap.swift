
import Foundation

import XCGLogger
import MapKit

class PlaceOnMap {

    // the mapstops on the map located at this place
    private var mapstopsOnMap: [MapstopOnMap]

    // if one of the mapstops at the place is the beginning of tour
    var hasTourBeginMapstop: Bool

    // if one of the mapstops at the place is part of an indoor tour
    var hasIndoorTourMapstop: Bool

    // The place that this is wrapping
    var place: Place

    // The index of the current mapstop selected by the user
    private var currentMapstop : Int

    var coordinate: CLLocationCoordinate2D {
        return place.coordinate
    }

    init(_ place: Place) {
        self.place = place
        self.mapstopsOnMap = Array()
        self.hasTourBeginMapstop = false
        self.hasIndoorTourMapstop = false
        self.currentMapstop = 0
    }

    func addMapstopOnMap(_ mapstopOnMap: MapstopOnMap) {
        self.mapstopsOnMap.append(mapstopOnMap)

        if(mapstopOnMap.isFirstInTour) {
            self.hasTourBeginMapstop = true
        }
        if(mapstopOnMap.isPartOfIndoorTour) {
            self.hasIndoorTourMapstop = true
        }
    }

    func hasMultipleMapstops() -> Bool {
        return (self.mapstopsOnMap.count > 1)
    }

    func currentMapstopOnMap() -> MapstopOnMap {
        return mapstopsOnMap[currentMapstop]
    }

    func nextMapstopOnMap() -> MapstopOnMap {
        currentMapstop = (currentMapstop + 1) % mapstopsOnMap.count
        return currentMapstopOnMap()
    }
    
}
