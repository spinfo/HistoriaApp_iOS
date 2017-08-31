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
    private static let ANNOTATION_OFFSET = CGPoint(x: 0, y: -20)

    // a handle to the marker, that this mapstop represents on the map
    private var marker: MaplyScreenMarker?

    // the annotation used to show information about the mapstops located at
    // this place
    private var annotation: MaplyAnnotation?

    // we keep an index to the currently previewed mapstop
    private var currentStopPreviewIdx = 0

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


    // when a place is selected, it shows a preview of it's mapstop(s)
    func onSelect(with mapViewC: MaplyViewController) {
        // initialize the annotation for this mapstop if need be
        if annotation == nil {
            annotation = MaplyAnnotation()
        }

        // get the current mapstop to display
        let idx = currentStopPreviewIdx % self.mapstopsOnMap.count
        let mapstop = self.mapstopsOnMap[idx].mapstop

        // fill fields
        annotation!.title = mapstop.name
        annotation!.subTitle = mapstop.description

        // Add an icon with which to switch through Mapstop previews
        if self.mapstopsOnMap.count > 1 {
            let nextLabel = createNextMapstopPreviewLabel()
            let labelTap = UITapGestureRecognizer(target: self, action: #selector(onNextMapstop))
            nextLabel.addGestureRecognizer(labelTap)
            annotation!.rightAccessoryView = nextLabel
        }

        // only one place is selected at any time
        mapViewC.clearAnnotations()
        mapViewC.addAnnotation(annotation, forPoint: self.place.getLocation(),
                               offset: PlaceOnMap.ANNOTATION_OFFSET)
    }

    @objc func onNextMapstop(_ sender: UITapGestureRecognizer) {
        self.currentStopPreviewIdx = (self.currentStopPreviewIdx + 1) % self.mapstopsOnMap.count
        // self.onSelect(with: self.mapViewC!)
        SpeedLog.print("Got click to next: \(currentStopPreviewIdx)")
    }


    // MARK: Private methods

    private func createNextMapstopPreviewLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        label.text = ">"
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.black
        label.isUserInteractionEnabled = true
        return label
    }
    
}
