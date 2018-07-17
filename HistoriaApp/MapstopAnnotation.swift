
import Foundation

import Mapbox

// A simple wrapper a mapox annotation allowing for the connection from
// annotation to the mapstop and the place on map
class PlaceAnnotation : MGLPointAnnotation {

    public var mapstop: Mapstop?

    public var placeOnMap: PlaceOnMap?

}

