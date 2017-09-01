//
//  PlaceOnMap.swift
//  HistoriaApp
//
//  Created by David on 30.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import SpeedLog
import WhirlyGlobe

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

    private static let MARKER_ICON_START = UIImage(named: "MarkerIconRed")
    private static let MARKER_ICON_DEFAULT = UIImage(named: "MarkerIconBlue")
    private static let MARKER_SIZE = CGSize(width: 40, height: 40)
    private static let MARKER_OFFSET = CGPoint(x: 0, y: 20)
    public static let ANNOTATION_OFFSET = CGPoint(x: 0, y: -20)

    // a handle to the marker, that this mapstop represents on the map
    private var marker: MaplyScreenMarker?

    // the annotation used to show information about the mapstops located at
    // this place
    private var annotation: MaplyAnnotation?

    // we keep an index to the currently previewed mapstop
    private var stopPreviewIdx = -1

    // create a marker to show this place on the map
    func createMarker() -> MaplyScreenMarker {
        // create an empty marker
        let marker = MaplyScreenMarker()
        marker.userObject = self
        marker.loc = self.place.getLocation()

        // which marker image to use depends on whether the place has the first
        // stop in a tour
        if self.hasTourBeginMapstop {
            marker.image = PlaceOnMap.MARKER_ICON_START
        } else {
            marker.image = PlaceOnMap.MARKER_ICON_DEFAULT
        }

        // set other default values
        marker.size = PlaceOnMap.MARKER_SIZE
        marker.offset = PlaceOnMap.MARKER_OFFSET

        return marker
    }

    // when a place is selected, it shows a preview of it's mapstop(s) in
    // an annotation, this selects the next mapstop to preview and returns
    // a MaplyAnnotation to do the preview with
    func nextAnnotation() -> MaplyAnnotation {
        // initialize the annotation for this mapstop if need be
        if annotation == nil {
            annotation = MaplyAnnotation()
        }

        // get the current mapstop to display
        stopPreviewIdx = (stopPreviewIdx + 1) % self.mapstopsOnMap.count
        let mapstop = self.mapstopsOnMap[stopPreviewIdx].mapstop

        // fill fields
        annotation!.title = mapstop.name
        annotation!.subTitle = mapstop.description
        return annotation!
    }

    // an optional label, that the client may add to the annotation to switch
    // throgh multiple mapstop previews
    func createNextMapstopPreviewLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        label.text = ">"
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.black
        label.isUserInteractionEnabled = true
        return label
    }
    
}
