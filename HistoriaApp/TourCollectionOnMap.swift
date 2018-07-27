
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
                mapstop.tour = tour

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

    func createAnnotations() -> [MKAnnotation] {
        return self.placesOnMap.map( { p in
            return PlaceOnMapAnnotation(p)
        })
    }

    func drawableTourTracks() -> [MKPolyline] {
        return self.tours.map( { tour -> MKPolyline in
            let coordinates = tour.trackCoordinates
            return MKPolyline(coordinates: coordinates, count: coordinates.count)
        })
    }

    public static func drawableTourTrackRenderer(for polyline: MKPolyline) -> MKPolylineRenderer {
        let renderer = MKPolylineRenderer(polyline: polyline)
        configureDrawableTourTrackRenderer(renderer)
        return renderer
    }

    private static func configureDrawableTourTrackRenderer(_ renderer: MKPolylineRenderer) {
        let color = UIColor(red: CGFloat(0x00) / 255.0, green: CGFloat(0x99) / 255.0, blue: CGFloat(0xCC) / 255.0, alpha: CGFloat(1))
        renderer.strokeColor = color
        renderer.lineWidth = CGFloat(2)
        renderer.lineCap = CGLineCap.square
        renderer.lineDashPattern = [4, 7]
    }

}
