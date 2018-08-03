
import UIKit

import MapKit
import XCGLogger

class MapViewController: UIViewController, UIPageViewControllerDataSource, MKMapViewDelegate, ModelSelectionDelegate {

    @IBOutlet var mapView: MKMapView!

    @IBOutlet weak var osmLicenseLinkButton: UIButton!

    @IBOutlet var calloutDetailView: MapstopOnMapCalloutDetailView!

    @IBOutlet var calloutNextMapstopButton: UIButton!

    private var tileRenderer: MKTileOverlayRenderer!

    private var currentAnnotations: [MKAnnotation] = Array()
    private var currentPolylines: [MKPolyline] = Array()

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
            log.error("Database init failed. Nothing to show.")
            return
        }

        self.setupTileRenderer()

        displayOSMCopyrightNotice()
        
        self.title = "HistoriaApp"

        self.mapView.delegate = self
        calloutDetailView.mapstopSelectionDelegate = self

        // actually display a tour
        let dao = MainDao()
        let firstTour = dao.getFirstTour()!
        self.tourSelected(firstTour)
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

    // MARK: -- Map Interaction (and MKMapViewDelegate)

    private func setupTileRenderer() {
        let template = "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png"
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
            log.error("Unexpected annotation type: \(type(of: annotation))")
            return nil
        }
        return castAnnotation.getOrCreateAnnotationView(reuseFrom: self.mapView)
    }

    // what happens when the user clicks on a marker
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let castAnnotation = castToPlaceOnMapAnnotation(annotation: view.annotation!) else {
            return
        }

        let mapstopOnMap = castAnnotation.placeOnMap.currentMapstopOnMap()
        prepareCalloutDetail(for: mapstopOnMap, on: view)

        if castAnnotation.placeOnMap.hasMultipleMapstops() {
            view.rightCalloutAccessoryView = calloutNextMapstopButton
        }

        castAnnotation.removeDummyTitle()
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let castAnnotation = castToPlaceOnMapAnnotation(annotation: view.annotation!) else {
            return
        }

        let mapstopOnMap = castAnnotation.placeOnMap.nextMapstopOnMap()
        switchCalloutDetailContent(with: mapstopOnMap, on: view)
    }

    private func castToPlaceOnMapAnnotation(annotation: MKAnnotation) -> PlaceOnMapAnnotation? {
        if let result = annotation as? PlaceOnMapAnnotation {
            return result
        } else {
            log.error("Unexpected annotation type: \(type(of: annotation))")
            return nil
        }
    }

    private func switchCalloutDetailContent(with mapstopOnMap: MapstopOnMap, on view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        prepareCalloutDetail(for: mapstopOnMap, on: view)
        mapView.selectAnnotation(view.annotation!, animated: false)
    }

    private func prepareCalloutDetail(for mapstopOnMap: MapstopOnMap, on view: MKAnnotationView) {
        calloutDetailView.updateContentForImmediateDisplay(using: mapstopOnMap)
        view.detailCalloutAccessoryView = calloutDetailView
    }

    // MARK: UIPageViewControllerDataSource

    // prepare the mastops page before the current one
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageViewC = viewController as? MapstopPageContentViewController else {
            log.error("Wrong page content view controller type")
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
            log.error("Wrong page content view controller type")
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
            log.error("Can't get page count for current mapstop.")
            return 0
        }
        return self.pages!.count
    }

    // tell the caller that we always start at the first mapstop page
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
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
        switchMapContents(to: TourCollectionOnMap(tour: tourWithAsscociations))
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

        self.switchMapContents(to: tourCollectionOnMap)
    }

    func mapstopSelected(_ mapstop: Mapstop) {
        // set the current pages
        let theDao = MainDao()
        self.pages = theDao.getPages(forMapstop: mapstop.id)

        // initialise a page view controller to manage the mapstop's places
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapstopPageViewController") as? UIPageViewController
        self.pageViewController!.dataSource = self

        guard let startingViewController = self.mapstopPageContentViewController(at: 0) else {
            log.error("Could not get page content controller for start index.")
            return
        }
        self.pageViewController!.setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)

        self.displayAsPopup(controller: pageViewController!)
    }

    // MARK: -- Map popups

    func displayAsPopup(controller: UIViewController) {
        closePopups()
        
        // a new MapPopupController is instantiated each time (seems necessary to correctly
        // adapt to the current device orientation)
        instantiateNewPopupController()
        self.mapPopupController!.setPopup(byController: controller)
    }

    func closePopups() {
        self.mapPopupController?.close()
        self.mapPopupController = nil
    }

    private func instantiateNewPopupController() {
        self.mapPopupController = self.storyboard?.instantiateViewController(withIdentifier: "MapPopupController") as? MapPopupController
        self.view.addSubview(self.mapPopupController!.view)
        self.mapPopupController!.didMove(toParentViewController: self)
    }

    // MARK: -- Drawer Navigation

    @IBAction func leftDrawerButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }


    // MARK: -- Private Methods

    private func switchMapContents(to tourCollection: TourCollectionOnMap) {
        removeMapContents()

        currentAnnotations = tourCollection.createAnnotations()
        mapView.addAnnotations(currentAnnotations)

        currentPolylines = tourCollection.drawableTourTracks()
        mapView.addOverlays(currentPolylines)

        zoomTo(tourCollectionOnMap: tourCollection)
    }

    private func removeMapContents() {
        mapView.removeOverlays(currentPolylines)
        currentPolylines.removeAll()

        mapView.removeAnnotations(currentAnnotations)
        currentAnnotations.removeAll()

        self.mapPopupController?.close()
    }

    private func zoomTo(tourCollectionOnMap: TourCollectionOnMap) {
        zoomTo(rect: makeRectFor(coords: tourCollectionOnMap.coordinates()))
    }

    private func zoomTo(rect: MKMapRect) {
        let n = CGFloat(40.0)
        let padding = UIEdgeInsets(top: n, left: n, bottom: n, right: n)
        mapView.setVisibleMapRect(rect, edgePadding: padding, animated: true)
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

    private func displayOSMCopyrightNotice() {
        self.view.bringSubview(toFront: self.osmLicenseLinkButton)
    }
}
