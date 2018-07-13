
import Foundation

import XCGLogger

// just for "rad2deg()" at the moment
import GLKit
import CoreLocation

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


    // construct a bounding box for a number of coordinates
    public static func makeBbox(_ coords: [MaplyCoordinate]) -> MaplyBoundingBox {
        // extrema to compare against
        var minLat = 90.0, maxLat = -90.0,
        minLon = 180.0, maxLon = 0.0

        for coord in coords {
            let lat = rad2deg(coord.y)
            let lon = rad2deg(coord.x)

            minLat = (lat < minLat) ? lat : minLat
            minLon = (lon < minLon) ? lon : minLon
            maxLat = (lat > maxLat) ? lat : maxLat
            maxLon = (lon > maxLon) ? lon : maxLon
        }
        let ll = MaplyCoordinateMakeWithDegrees(Float(minLon), Float(minLat))
        let ur = MaplyCoordinateMakeWithDegrees(Float(maxLon), Float(maxLat))

        // return a bounding box for those corners
        return MaplyBoundingBox(ll: ll, ur: ur)
    }

    public static func bboxCenter(_ box: MaplyBoundingBox) -> MaplyCoordinate {
        let xAdd = (box.ur.x - box.ll.x) / 2
        let yAdd = (box.ur.y - box.ll.y) / 2
        return MaplyCoordinateMake(box.ll.x + xAdd, box.ll.y + yAdd)
    }

    private static func rad2deg(_ radians: Float) -> Double {
        return CLLocationDegrees(GLKMathRadiansToDegrees(radians))
    }
 
    */

}
