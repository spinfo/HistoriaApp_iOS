
import Foundation

import XCGLogger

// just for "rad2deg()" at the moment
import GLKit
import CoreLocation

import Mapbox

// some static methods to extract map functionality
class MapUtil {

    /*
    
    // how a tour's tracks vector looks
    static let lineDesc: [String: Any] = [
        kMaplyColor: UIColor(red: 0.1, green: 0.3, blue: 1, alpha: 0.5) ,
        kMaplyVecWidth: 9.0
    ]

    // the track that marks a tour's path on the map
    public static func getVectorForTrack(_ track: [PersistableGeopoint]) -> MaplyVectorObject {
        var lineCoords = track.map { p in return p.toCoordinate() }
        return MaplyVectorObject(lineString: &lineCoords, numCoords: Int32(lineCoords.count), attributes: lineDesc)
    }
     */

    // construct a bounding box for a number of coordinates
    public static func makeBbox(_ coords: [CLLocationCoordinate2D]) -> MGLCoordinateBounds {
        // extrema to compare against
        var minLat = 90.0,  maxLat = -90.0,
            minLon = 180.0, maxLon = 0.0

        for coord in coords {
            let lat = coord.latitude
            let lon = coord.longitude

            minLat = (lat < minLat) ? lat : minLat
            minLon = (lon < minLon) ? lon : minLon
            maxLat = (lat > maxLat) ? lat : maxLat
            maxLon = (lon > maxLon) ? lon : maxLon
        }

        // return a bounding box for those corners
        let sw = CLLocationCoordinate2D(latitude: minLat, longitude: minLon)
        let ne = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)
        return MGLCoordinateBounds(sw: sw, ne: ne)
    }


    public static func bboxCenter(_ box: MGLCoordinateBounds) -> CLLocationCoordinate2D {
        let xAdd = (box.ne.longitude - box.sw.longitude) / 2
        let yAdd = (box.ne.latitude - box.sw.latitude) / 2
        return CLLocationCoordinate2D(latitude: box.sw.longitude + yAdd, longitude: box.ne.longitude + xAdd)
    }
}
