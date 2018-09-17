
import UIKit

import MapKit
import XCGLogger

class MapViewController: UIViewController, MKMapViewDelegate, ModelSelectionDelegate, AreaProvider, MapPopupOnCloseDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!

    @IBOutlet weak var osmLicenseLinkButton: UIButton!

    @IBOutlet var calloutNextMapstopButton: UIButton!

    @IBOutlet weak var userLocationButton: UIButton!

    private var mapState: MapState?

    private var locationManager: CLLocationManager!

    private var tileRenderer: MKTileOverlayRenderer!

    private var currentAnnotations: [MKAnnotation] = Array()
    private var currentPolylines: [MKPolyline] = Array()

    // a controller for poups over the map
    private var mapPopupController: MapPopupController?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard DatabaseHelper.initDB() else {
            log.error("Database init failed. Nothing to show.")
            return
        }
        self.setupTileRenderer()

        renewObserverStatusForAppSuspending()

        bringMapUIElementsToTheFront()
        removeMapkitLegalAttributionLabel(in: mapView)

        mapView.delegate = self

        mapState = MapState.restoreOrDefault()
        switchMapContents(to: mapState!.tourCollection)
        zoom(basedOn: mapState!)

        mapView.isRotateEnabled = false
        determineTitle()
        setupLocationManager()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.debug("Saving map state on view disappearing.")
        mapState?.persist()
    }

    @objc func appWillSuspend() {
        log.debug("Saving map state on app suspending.")
        mapState?.persist()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mapPopupController?.viewWillTransition(to: size, with: coordinator)
    }

    private func renewObserverStatusForAppSuspending() {
        stopObservingNotifications()
        let names = [
            NSNotification.Name.UIApplicationWillTerminate,
            NSNotification.Name.UIApplicationWillResignActive
        ]
        for name in names {
            NotificationCenter.default.addObserver(self, selector: #selector(appWillSuspend), name: name, object: nil)
        }
    }

    private func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // tapping the copyright link int the lower left corner opens the osm page in browser
    @IBAction func osmLicenseLinkButtonTapped(_ sender: Any) {
        let url = URL(string: "https://www.openstreetmap.org/copyright/")
        UIApplication.shared.openURL(url!)
    }

    private func determineTitle() {
        determineTitle(with: getCurrentArea())
    }

    private func determineTitle(with area: Area) {
        self.title = String(format: "HistoriaApp: %@", area.name)
    }

    // MARK: -- Map Interaction (and MKMapViewDelegate)

    private func setupTileRenderer() {
        let template = "http://tile.openstreetmap.com/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.add(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            return tileRenderer
        } else if overlay is MKPolyline {
            return TourCollectionOnMap.drawableTourTrackRenderer(for: overlay as! MKPolyline)
        } else {
            log.warning("Render request for unknown overlay type: \(String(describing: overlay))")
            return MKOverlayRenderer()
        }
    }

    // Determine the view that should be rendered to indicate a point of interest on the map.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let castAnnotation = annotation as? PlaceOnMapAnnotation else {
            return nil
        }

        let mapstopOnMap = castAnnotation.setupForCurrentMapstop()
        let annotationView = castAnnotation.getOrCreateAnnotationView(reuseFrom: self.mapView)
        annotationView.updateContent(with: mapstopOnMap)
        annotationView.mapstopSelectionDelegate = self
        if castAnnotation.placeOnMap.hasMultipleMapstops() {
            annotationView.rightCalloutAccessoryView = calloutNextMapstopButton
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let castAnnotation = castToPlaceOnMapAnnotation(annotation: view.annotation!) else {
            return
        }

        mapView.deselectAnnotation(castAnnotation, animated: false)
        let mapstop = castAnnotation.setupForNextMapstop()
        (view as! PlaceOnMapAnnotationView).updateContent(with: mapstop)
        mapView.selectAnnotation(view.annotation!, animated: false)
    }

    private func castToPlaceOnMapAnnotation(annotation: MKAnnotation) -> PlaceOnMapAnnotation? {
        if let result = annotation as? PlaceOnMapAnnotation {
            return result
        } else {
            log.error("Unexpected annotation type: \(type(of: annotation))")
            return nil
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapState?.visibleMapRegion = mapView.visibleMapRect
    }

    // MARK: -- ModelSelectionDelegate

    func tourSelectedForPreview(_ tour: Tour) {
        guard let tourWithAsscociations = refetchTourForMapDisplayLoggingOnError(tour) else {
            return
        }

        let tourPreviewController = storyboard?.instantiateViewController(withIdentifier: "TourPreviewController") as! TourPreviewController
        tourPreviewController.tour = tourWithAsscociations
        tourPreviewController.tourSelectionDelegate = self
        displayAsPopup(controller: tourPreviewController)
    }

    func tourPreviewAborted() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchToTourSelection()
    }

    func tourSelected(_ tour: Tour) {
        log.debug("Request to select tour: \(tour.name)")
        guard let tourWithAsscociations = refetchTourForMapDisplayLoggingOnError(tour) else {
            return
        }
        requestCenter()
        let tourCollection = TourCollectionOnMap(tour: tourWithAsscociations)
        switchMapContents(to: tourCollection)
        zoomTo(tourCollectionOnMap: tourCollection)
    }

    private func refetchTourForMapDisplayLoggingOnError(_ tour: Tour) -> Tour? {
        // we need to re-retrieve the tour here because we don't know if all connections are
        // present.
        let dao = MainDao()
        guard let tourWithAssociations = dao.getTourWithAssociationsForMapping(id: tour.id) else {
            log.error("Unable to retrieve tour (id: \(tour.id)) with associations.")
            return nil
        }
        return tourWithAssociations
    }

    private func requestCenter() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestCenter(for: self)
    }

    func areaSelected(_ area: Area) {
        let dao = MainDao()
        let tours = dao.getToursWithAssociationsForMapping(inAreaWithId: area.id)
        let tourCollectionOnMap = TourCollectionOnMap(tours: tours)

        requestCenter()

        switchMapContents(to: tourCollectionOnMap)
        zoomTo(tourCollectionOnMap: tourCollectionOnMap)
        determineTitle(with: area)
    }

    func mapstopSelected(_ mapstop: Mapstop) {
        let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapstopPageViewController") as? MapstopPageViewController
        pageViewController!.mapstop = mapstop

        self.displayAsPopup(controller: pageViewController!)
    }

    // MARK: -- AreaProvider

    func getCurrentArea() -> Area {
        let currentArea = determineCurrentAreaByCurrentTours()

        if (currentArea == nil) {
            log.warning("No area determinable by map state. Defaulting to first in db.")
            return MainDao().getFirstArea()!
        } else {
            return currentArea!
        }
    }

    private func determineCurrentAreaByCurrentTours() -> Area? {
        if mapState!.tourCollection.isEmpty() {
            return nil
        }
        let areas = MainDao().getAreas(belongingTo: mapState!.tourCollection.tours)
        return areas.first
    }

    // MARK: -- Map popups

    func displayAsPopup(controller: UIViewController) {
        if (mapPopupController == nil) {
            instantiateNewPopupController()
        }
        self.mapPopupController!.setPopup(byController: controller)
    }

    func closePopups() {
        self.mapPopupController?.close()
    }

    func onMapPopupClose() {
        self.mapPopupController = nil
    }

    private func instantiateNewPopupController() {
        mapPopupController = self.storyboard?.instantiateViewController(withIdentifier: "MapPopupController") as? MapPopupController
        view.addSubview(self.mapPopupController!.view)
        mapPopupController!.closeDelegate = self
        mapPopupController!.didMove(toParentViewController: self)
    }

    // MARK: -- Drawer Navigation

    @IBAction func leftDrawerButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }


    // MARK: -- User Location

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != .authorizedWhenInUse) {
            return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }

    @IBAction func userLocationButtonTapped() {
        let coordinate = locationManager.location?.coordinate
        if (coordinate != nil) {
            mapView.centerCoordinate = coordinate!
        } else {
            log.debug("No user location to show.")
        }
    }

    // MARK: -- Private Methods

    private func zoom(basedOn state: MapState) {
        if (!state.hasDefaultRegionSet()) {
            zoomTo(rect: state.visibleMapRegion, padding: 0)
        }
        else if (!state.tourCollection.isEmpty())  {
            zoomTo(tourCollectionOnMap: state.tourCollection)
        }
        else {
            log.warning("Cannot zoom based on previous map state, using default region.")
            zoomTo(rect: MapState.defaultMapRegion, padding: 0)
        }
    }

    private func switchMapContents(to tourCollection: TourCollectionOnMap) {
        removeMapContents()

        currentAnnotations = tourCollection.createAnnotations()
        mapView.addAnnotations(currentAnnotations)

        currentPolylines = tourCollection.drawableTourTracks()
        mapView.addOverlays(currentPolylines)

        mapState?.tourCollection = tourCollection
    }

    private func removeMapContents() {
        mapView.removeOverlays(currentPolylines)
        currentPolylines.removeAll()

        mapView.removeAnnotations(currentAnnotations)
        currentAnnotations.removeAll()

        self.mapPopupController?.close()
    }

    private func zoomTo(tourCollectionOnMap: TourCollectionOnMap) {
        zoomTo(rect: makeRectFor(coords: tourCollectionOnMap.coordinates()), padding: 40)
    }

    private func zoomTo(rect: MKMapRect, padding: Int) {
        if (padding > 0) {
            let insets = makeEqualSidedEdgeInsets(distance: padding)
            mapView.setVisibleMapRect(rect, edgePadding: insets, animated: false)
        } else {
            mapView.setVisibleMapRect(rect, animated: false)
        }
    }

    private func makeEqualSidedEdgeInsets(distance: Int) -> UIEdgeInsets {
        let n = CGFloat(distance)
        return UIEdgeInsets(top: n, left: n, bottom: n, right: n)
    }

    private func makeRectFor(coords: [CLLocationCoordinate2D]) -> MKMapRect {
        var rect = MKMapRectNull
        for coord in coords {
            let point = MKMapPointForCoordinate(coord)
            let pointRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
            rect = MKMapRectUnion(rect, pointRect)
        }
        return rect
    }

    private func bringMapUIElementsToTheFront() {
        self.view.bringSubview(toFront: self.osmLicenseLinkButton)
        self.view.bringSubview(toFront: self.userLocationButton)
    }

    private func removeMapkitLegalAttributionLabel(in view: UIView) {
        for subview in view.subviews {
            if String(describing: type(of: subview)) == "MKAttributionLabel" {
                subview.removeFromSuperview()
                return
            }
            removeMapkitLegalAttributionLabel(in: subview)
        }
    }
}
