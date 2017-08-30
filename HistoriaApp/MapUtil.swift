//
//  MapUtil.swift
//  HistoriaApp
//
//  Created by David on 25.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import WhirlyGlobe
import SpeedLog

// just for "rad2deg()" at the moment
import GLKit
import CoreLocation

// some static methods to extract map functionality
class MapUtil {

    public static func buildDefaultMarker(for mapstop: Mapstop?) -> MaplyScreenMarker {
        // create an empty marker
        let marker = MaplyScreenMarker()

        // set the image
        let markerIcon = UIImage(named: "MarkerIconBlue")
        marker.image = markerIcon

        // set other default values
        marker.size = CGSize(width: 40, height: 40)
        marker.offset = CGPoint(x: 0, y: 20)
        marker.userObject = mapstop

        // set the location if possible
        guard let location = mapstop?.place?.getLocation() else {
            SpeedLog.print("WARN", "Not setting location for marker.")
            return marker
        }
        marker.loc = location

        return marker
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

}
