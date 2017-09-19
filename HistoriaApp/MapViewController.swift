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

class MapViewController: UIViewController, MaplyViewControllerDelegate, UIPageViewControllerDataSource,
                        MapPopupDelegate, ModelSelectionDelegate {

    // the controller used for manipulating the map
    private var mapViewC: MaplyViewController?

    // This saves handles for the currently drawn objects for later removal
    private var currentlyDrawn: [MaplyComponentObject] = Array()

    // The placeOnMap currently selected
    private var selectedPlaceOnMap: PlaceOnMap?

    // A controller showing a mapstop's pages if one is selected
    private var pageViewController: UIPageViewController?

    // The currently selected mapstops pages
    private var pages: [Page]?

    // a controller for poups over the map
    private var mapPopupController: MapPopupController?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard DatabaseHelper.initDB() else {
            SpeedLog.print("Database init failed. Nothing to show.")
            return
        }

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

        // actually display a tour
        let dao = MasterDao()
        let firstTour = dao.getFirstTour()!
        self.tourSelected(firstTour)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: -- Map Interaction (and MaplyViewControllerDelegate)

    // A tap made directly to the map
    func maplyViewController(_ viewC: MaplyViewController!, didTapAt coord: MaplyCoordinate) {
        // clear annotations for a selected place on map and remove the selection
        mapViewC?.clearAnnotations()
        self.selectedPlaceOnMap = nil
    }

    // A tap to a marker (or possibly another object)
    func maplyViewController(_ viewC: MaplyViewController!, didSelect selectedObj: NSObject!) {
        if let marker = selectedObj as? MaplyScreenMarker {
            guard let placeOnMap = marker.userObject as? PlaceOnMap else {
                SpeedLog.print("WARN", "Marker without associated PlaceOnMap.")
                return
            }
            self.showNextAnnotation(for: placeOnMap)
        } else {
            SpeedLog.print("INFO", "Click to other object: \(selectedObj)")
        }
    }

    // handle a click to the "next" label inside a mapstop annotation
    func onNextMapstopPreviewClick() {
        guard self.selectedPlaceOnMap != nil else {
            SpeedLog.print("ERROR", "No place on map selected.")
            return
        }
        showNextAnnotation(for: self.selectedPlaceOnMap!)
    }

    // handle a tap to an annotation: show that mapstop's pages
    func maplyViewController(_ viewC: MaplyViewController!, didTap annotation: MaplyAnnotation!) {
        print("Tapped annotation: \(annotation)")

        guard let mapstop = (annotation as? MapstopAnnotation)?.mapstop else {
            SpeedLog.print("ERROR", "No mapstop for annotation")
            return
        }

        // set the current pages
        let theDao = MasterDao()
        self.pages = theDao.getPages(forMapstop: mapstop.id)

        // initialise a page view controller to manage the mapstop's places
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapstopPageViewController") as? UIPageViewController
        self.pageViewController?.dataSource = self

        guard let startingViewController = self.mapstopPageContentViewController(at: 0) else {
            SpeedLog.print("ERROR", "Could not get page content controller for start index.")
            return
        }
        self.pageViewController?.setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)

        // actually display the page view controller as a popup
        self.mapPopupController = self.storyboard?.instantiateViewController(withIdentifier: "MapPopupController") as? MapPopupController
        self.view.addSubview(self.mapPopupController!.view)
        self.mapPopupController!.didMove(toParentViewController: self)
        self.mapPopupController!.setPopup(byController: self.pageViewController!)
        self.mapPopupController!.delegate = self
    }

    // MARK: UIPageViewControllerDataSource

    // prepare the mastops page before the current one
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageViewC = viewController as? MapstopPageContentViewController else {
            SpeedLog.print("ERROR", "Wrong page content view controller type")
            return nil
        }

        if (pageViewC.pageIndex == nil || pageViewC.pageIndex! <= 0) {
            return nil
        }

        pageViewC.pageIndex! -= 1
        return self.mapstopPageContentViewController(at: pageViewC.pageIndex!)
    }

    // prepare the mastops page after the current one
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageViewC = viewController as? MapstopPageContentViewController else {
            SpeedLog.print("ERROR", "Wrong page content view controller type")
            return nil
        }

        if (pageViewC.pageIndex == nil) {
            return nil
        }

        pageViewC.pageIndex! += 1
        return self.mapstopPageContentViewController(at: pageViewC.pageIndex!)
    }

    private func mapstopPageContentViewController(at idx: Int) -> MapstopPageContentViewController? {
        guard self.pages != nil && idx >= 0 && idx < self.pages!.count  else {
            SpeedLog.print("WARN", "No pages")
            return nil
        }

        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MapstopPageContentViewController") as! MapstopPageContentViewController

        controller.pageIndex = idx
        controller.page = pages?[idx]
        return controller
    }

    // tell the caller how many pages the currently selected mapstop has
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        guard self.pages != nil else {
            SpeedLog.print("ERROR", "Can't get page count for current mapstop.")
            return 0
        }
        return self.pages!.count
    }

    // tell the caller that we always start at the first mapstop page
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

    // MARK: -- ModelSelectionDelegate

    func tourSelected(_ tour: Tour) {
        SpeedLog.print("INFO", "Request to select tour: \(tour.name)")
        // we need to re-retrieve the tour here because we don't know if all connections are
        // present. (We could test, but they won't be in all current cases anyway.)
        let dao = MasterDao()
        guard let tourAssoc = dao.getTourWithAssociationsForMapping(id: tour.id) else {
            SpeedLog.print("ERROR", "Unable to retrieve tour (id: \(tour.id)) with associations.")
            return
        }
        let tourCollectionOnMap = TourCollectionOnMap(tours: [tourAssoc])

        // the map view should always request to be the center view when a tour is selected
        SpeedLog.print("--- requesting center view for map")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestCenter(for: self)

        // initiate the switch only after we are on center so that the animation works
        self.switchTo(tourCollection: tourCollectionOnMap)
    }

    func areaSelected(_ area: Area) {
        // Do nothing for now
    }

    // MARK: -- MapPopupDelegate

    func requestedPopupClose(sender: MapPopupController) {
        sender.willMove(toParentViewController: nil)
        sender.view.removeFromSuperview()
        sender.removeFromParentViewController()
    }

    // MARK: -- Drawer Navigation

    @IBAction func leftDrawerButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }


    // MARK: -- Private Methods

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
    private func switchTo(tourCollection: TourCollectionOnMap) {
        // remove the old markers and setup new ones
        self.clearTheMap()
        let markers = tourCollection.placesOnMap.map { p in return p.createMarker() }
        guard let markersHandle = mapViewC?.addScreenMarkers(markers, desc: nil) else {
            SpeedLog.print("WARN", "No components created on creating markers")
            return
        }
        currentlyDrawn.append(markersHandle)

        // position the map to the markers
        let box = MapUtil.makeBbox(markers.map({ m in return m.loc }))
        let center = MapUtil.bboxCenter(box)
        let height = mapViewC!.myFindHeight(bbox: box)
        mapViewC!.height = height
        mapViewC!.animate(toPosition: center, time: 0.0)
    }

    // Show an annotation view for a place on the map
    private func showNextAnnotation(for placeOnMap: PlaceOnMap) {
        let annotation = placeOnMap.nextAnnotation()

        // If the placeOnMap has multiple mapstops, set it up to switch through those
        if placeOnMap.mapstopsOnMap.count > 1 {
            let nextLabel = placeOnMap.createNextMapstopPreviewLabel()
            let labelTap = UITapGestureRecognizer(target: self, action: #selector(onNextMapstopPreviewClick))
            nextLabel.addGestureRecognizer(labelTap)
            annotation.rightAccessoryView = nextLabel
        }

        // only one annotation is shown at any time
        mapViewC?.clearAnnotations()
        mapViewC?.addAnnotation(annotation, forPoint: placeOnMap.place.getLocation(),
                                offset: PlaceOnMap.ANNOTATION_OFFSET)
        self.selectedPlaceOnMap = placeOnMap
    }
}

fileprivate extension MaplyViewController {

    // finds a good height to display all of the given bounding box on the current
    // map view
    // (Implemented here because WhirlyGlobes findHeight() did not really work for small boxes)
    // TODO: This seems not to work for some tours
    //      * not at all: "Judendeportation etc."
    //      * a little to narrow: "Auswirkungen und Folgen etc."
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

        // an additional factor to use when zooming out (1.0 would mean one additional zoom level)
        let plusZoom = Float(0.25)

        for i in stride(from: 1.0, to: 20.0, by: 1.0) {

            let tilesAmount = pow(2.0, i)

            // how many pixels would a map for that distance have at the given zoom level
            // assume 256 pixels per tile
            let pixels = (256.0 *  eqFrac * tilesAmount)

            // if the map's pixels are more than the screen diagonal, we have gone too far
            // so return the last correct height plus plus added offset
            // also break if we got below the minimum height
            if (pixels > screenDist || zoomHeight < minHeight) {
                return (zoomHeight * (2 + (2 * plusZoom)))
            }
            
            // halve the height for the next iteration
            zoomHeight /= 2
        }
        
        SpeedLog.print("WARN", "Calculating the zoom height did not terminate.")
        return zoomHeight * 4
    }
}
