//
//  ViewController.swift
//  HistoriaApp
//
//  Created by David on 10.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import WhirlyGlobe
import SpeedLog

class ViewController: UIViewController, MaplyViewControllerDelegate {

    // the controller used for manipulating the map
    private var mapViewC: MaplyViewController?

    // This saves handles for the currently drawn objects for later removal
    private var currentlyDrawn: [MaplyComponentObject] = Array()

    override func viewDidLoad() {
        super.viewDidLoad()

        // use the file service to install the example data
        guard let tourAfterInstall = FileService.installExampleTour() else {
            SpeedLog.print("ERROR", "Error installing examples.")
            return
        }

        let dao = MasterDao()
        guard let tour = dao.getTourWithAssociationsForMapping(id: tourAfterInstall.id) else {
            SpeedLog.print("ERROR", "Unable to retrieve tour with associations.")
            return
        }

        // map stuff
        // Create an empty map and add it to the view
        mapViewC = MaplyViewController(asFlatMap: ())
        self.view.addSubview(mapViewC!.view)
        mapViewC!.view.frame = self.view.bounds
        addChildViewController(mapViewC!)

        // make this the delegate for tap events
        mapViewC?.delegate = self

        // set a white background for the map
        mapViewC!.clearColor = UIColor.white

        // try 30 fps (set to 3 if the app struggles)
        mapViewC!.frameInterval = 2

        // this is the map's baselayer
        var layer: MaplyQuadImageTilesLayer

        // setup cache directory for the remote tile set
        let baseCacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let tilesCacheDir = "\(baseCacheDir)/tiles/"

        // setup the tile source and options
        guard let tileSource = MaplyRemoteTileSource(
            baseURL: "http://tile.openstreetmap.org/",
            ext: "png",
            minZoom: 0,
            maxZoom: 18) else {
                fatalError("Can't create remote tile source.")
        }
        tileSource.cacheDir = tilesCacheDir
        layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys, tileSource: tileSource)

        // set map layer options
        layer.handleEdges = false
        layer.coverPoles = false
        layer.requireElev = false
        layer.waitLoad = false
        layer.drawPriority = 0
        layer.singleLevelLoading = false
        layer.enable = true
        mapViewC!.add(layer)

        // marker creation
        let tourCollectionOnMap = TourCollectionOnMap(tours: [tour])
        let markers = tourCollectionOnMap.placesOnMap.map { p in return p.createMarker() }

        // position the map to the markers
        let box = MapUtil.makeBbox(markers.map({ m in return m.loc }))
        let center = MapUtil.bboxCenter(box)
        let height = mapViewC!.myFindHeight(bbox: box)

        mapViewC!.height = height
        mapViewC!.animate(toPosition: center, time: 0.0)
        guard let markersHandle = mapViewC?.addScreenMarkers(markers, desc: nil) else {
            SpeedLog.print("WARN", "No components created on creating markers")
            return
        }
        currentlyDrawn.append(markersHandle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: -- Map Interaction

    // A tap made directly to the map
    func maplyViewController(_ viewC: MaplyViewController!, didTapAt coord: MaplyCoordinate) {
        mapViewC?.clearAnnotations()
    }

    // A tap to a marker (or possibly another object)
    func maplyViewController(_ viewC: MaplyViewController!, didSelect selectedObj: NSObject!) {
        if let marker = selectedObj as? MaplyScreenMarker {
            guard let placeOnMap = marker.userObject as? PlaceOnMap else {
                SpeedLog.print("WARN", "Marker without associated PlaceOnMap.")
                return
            }
            placeOnMap.onSelect(with: mapViewC!)
        } else {
            SpeedLog.print("INFO", "Click to other object: \(selectedObj)")
        }
    }

    //MARK: -- Private Methods

    // clear the map of all objects we might have added
    private func clearTheMap() {
        // remove everything drawn so far
        for handle in currentlyDrawn {
            mapViewC?.remove(handle)
        }
        currentlyDrawn = Array()

        // remove annotations
        mapViewC?.clearAnnotations()
    }

    // Remove all other content on the map and only display the given
    // collection of tours
    private func switchTo(tourCollection: TourCollectionOnMap?) {
        self.clearTheMap()


    }

}

fileprivate extension MaplyViewController {

    func myFindHeight(bbox: MaplyBoundingBox) -> Float {

        // calculate distance in meters
        let distance = MaplyGreatCircleDistance(bbox.ll, bbox.ur)

        // calculate screen diagonal in pixels
        let screenDist = Double(sqrt(pow(self.view.frame.height, 2) + pow(self.view.frame.width, 2)))

        // the equator has about 40 million meters
        let eqFrac = distance / 40000000

        // note the min and max highest zoom level, the latter will be halved to get a fit
        // TODO: Set these to self.getMinZoom() and self.getMaxZoom() once we are on WhirlyGlobe 2.5
        let minHeight = Float(0.000001)
        var zoomHeight = Float(5.0)

        for i in stride(from: 1.0, to: 20.0, by: 1.0) {

            let tilesAmount = pow(2.0, i)

            // how many pixels would a map for that distance have at the given zoom level
            // assume 256 pixels per tile
            let pixels = (256.0 *  eqFrac * tilesAmount)

            // if the map's pixels are more than the screen diagonal, we have gone too far
            // so return the last correct height
            // also break if we got below the minimum height
            if (pixels > screenDist || zoomHeight < minHeight) {
                return (zoomHeight * 2)
            }
            
            // halve the height for the next iteration
            zoomHeight /= 2
            
        }
        
        SpeedLog.print("WARN", "Calculating the zoom height did not terminate.")
        return zoomHeight * 4
    }
}
