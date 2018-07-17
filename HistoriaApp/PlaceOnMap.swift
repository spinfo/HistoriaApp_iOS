
import Foundation

import XCGLogger
import Mapbox

class PlaceOnMap {

    // the mapstops on the map located at this place
    var mapstopsOnMap: [MapstopOnMap]

    // if one of the mapstops at the place is the beginning of tour
    var hasTourBeginMapstop: Bool

    // The place that this is wrapping
    var place: Place

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

    // MARK: Display on the map

    // Method to get a geographical point from the place's lat/lon
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
    }




    // an optional label, that the client may add to the annotation to switch
    // throgh multiple mapstop previews
    /*
    func createNextMapstopPreviewLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        label.text = ">"
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.black
        label.isUserInteractionEnabled = true
        return label
    }
    */
    
}
