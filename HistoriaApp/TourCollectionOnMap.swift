
import Foundation

import XCGLogger
import MapKit

// A class used to prepare a bunch of tours to be dispplayed on the map
// - 1st use: Set all relevant attributes of models to be displayed on the map
// - 2nd use: Provide other direction of association (1 Place -> n Mapstops)
//            for the tours represented by this collection
public class TourCollectionOnMap {

    // the tours this represents on the map
    var tours: [Tour]

    // the places contained in the tours represented
    var placesOnMap: [PlaceOnMap]

    // creates a TourCollectionOnMap and initializes the nested xOnMap objects
    // with all variables set, ready to be displayed
    // NOTE: Does not fetch from the db, but assumes, that alle objects to be
    // shown on the map (Tours, Mapstops, Places) are ready to display.
    init(tours: [Tour]) {
        self.tours = tours

        // keep a map of the PlaceOnMap created for re-use
        var placesOnMapById: [Int64:PlaceOnMap] = Dictionary()

        for tour in tours {
            var isFirstStop = true

            for mapstop in tour.mapstops {
                let stopOnMap = MapstopOnMap(mapstop)

                // indicate the first stop in the tour
                if(isFirstStop) {
                    stopOnMap.isFirstInTour = true
                    isFirstStop = false
                }

                guard let place = mapstop.place else {
                    log.warning("No place for mapstop. Skipping.")
                    continue
                }

                // link PlaceOnMap and MapstopOnMap
                var placeOnMap = placesOnMapById[place.id]
                if (placeOnMap == nil) {
                    placeOnMap = PlaceOnMap(place)
                }
                placeOnMap!.addMapstopOnMap(stopOnMap)

                placesOnMapById[place.id] = placeOnMap
            }
        }
        // set the result
        self.placesOnMap = Array(placesOnMapById.values)
    }

    func coordinates() -> [CLLocationCoordinate2D] {
        var result: [CLLocationCoordinate2D] = Array()
        for tour in tours {
            result += tour.coordinates
        }
        return result
    }

}
