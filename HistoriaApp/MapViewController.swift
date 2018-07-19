
import UIKit

import MapKit
import XCGLogger

class MapViewController: UIViewController, UIPageViewControllerDataSource, MKMapViewDelegate, ModelSelectionDelegate {

    @IBOutlet var mapView: MKMapView!

    @IBOutlet weak var osmLicenseLinkButton: UIButton!

    private var tileRenderer: MKTileOverlayRenderer!

    private var currentAnnotations: [MKAnnotation] = Array()

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

        // (re) draw the copyright notice now hidden behind the map view
        drawOSMCopyrightNotice()
        
        self.title = "HistoriaApp"

        self.setupTileRenderer()
        self.mapView.delegate = self

        // actually display a tour
        let dao = MasterDao()
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

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        log.debug(String(describing: tileRenderer))
        return tileRenderer
    }

    private func setupTileRenderer() {
        let template = "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.add(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(overlay: overlay)
    }
    /*
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
                log.warning("Marker without associated PlaceOnMap.")
                return
            }
            self.showNextAnnotation(for: placeOnMap)
        } else {
            log.info("Click to other object: \(selectedObj)")
        }
    }

    // handle a click to the "next" label inside a mapstop annotation
    func onNextMapstopPreviewClick() {
        guard self.selectedPlaceOnMap != nil else {
            log.error("No place on map selected.")
            return
        }
        showNextAnnotation(for: self.selectedPlaceOnMap!)
    }

    // handle a tap to an annotation: show that mapstop's pages
    func maplyViewController(_ viewC: MaplyViewController!, didTap annotation: MaplyAnnotation!) {
        guard let mapstop = (annotation as? MapstopAnnotation)?.mapstop else {
            log.error("No mapstop for annotation")
            return
        }

        // set the current pages
        let theDao = MasterDao()
        self.pages = theDao.getPages(forMapstop: mapstop.id)

        // initialise a page view controller to manage the mapstop's places
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapstopPageViewController") as? UIPageViewController
        self.pageViewController!.dataSource = self

        guard let startingViewController = self.mapstopPageContentViewController(at: 0) else {
            log.error("Could not get page content controller for start index.")
            return
        }
        self.pageViewController!.setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)

        // actually display the page view controller as a popup
        self.displayPopup(controller: pageViewController!)
    }

    */

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

    func tourSelected(_ tour: Tour) {
        log.info("Request to select tour: \(tour.name)")
        // we need to re-retrieve the tour here because we don't know if all connections are
        // present. (We could test, but they won't be in all current cases anyway.)
        let dao = MasterDao()
        guard let tourWithAssociations = dao.getTourWithAssociationsForMapping(id: tour.id) else {
            log.error("Unable to retrieve tour (id: \(tour.id)) with associations.")
            return
        }
        let tourCollectionOnMap = TourCollectionOnMap(tours: [tourWithAssociations])

        // the map view should always request to be the center view when a tour is selected
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestCenter(for: self)

        // initiate the switch only after we are on center so that the animation works
        self.switchMapContents(to: tourCollectionOnMap)
    }

    func areaSelected(_ area: Area) {
        let dao = MasterDao()
        let tours = dao.getToursWithAssociationsForMapping(inAreaWithId: area.id)
        let tourCollectionOnMap = TourCollectionOnMap(tours: tours)

        // the map view should always request to be the center view when an area is selected
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestCenter(for: self)

        self.switchMapContents(to: tourCollectionOnMap)
    }

    // MARK: -- Map popups

    func displayPopup(controller: UIViewController) {
        if self.mapPopupController != nil {
            self.mapPopupController!.close()
            self.mapPopupController = nil
        }
        // a new MapPopupController is instantiated each time (seems necessary to correctly
        // adapt to the current device orientation)
        self.mapPopupController = self.storyboard?.instantiateViewController(withIdentifier: "MapPopupController") as? MapPopupController
        self.view.addSubview(self.mapPopupController!.view)
        self.mapPopupController!.didMove(toParentViewController: self)
        self.mapPopupController!.setPopup(byController: controller)
    }

    func closePopups() {
        self.mapPopupController?.close()
    }

    // MARK: -- Drawer Navigation

    @IBAction func leftDrawerButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }


    // MARK: -- Private Methods

    // clear the map of all objects we might have added
    private func clearTheMap() {

        //TODO

        // close popups
        self.mapPopupController?.close()
    }

    // Remove all other content on the map and only display the given
    // collection of tours
    private func switchMapContents(to tourCollection: TourCollectionOnMap) {

        // remove everything drawn before
        self.clearTheMap()

        for p in tourCollection.placesOnMap {
            let annotation = PlaceOnMapAnnotation(p)
            mapView.addAnnotation(annotation)
        }

        zoomTo(tourCollectionOnMap: tourCollection)
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

    private func zoomTo(tourCollectionOnMap: TourCollectionOnMap) {
        zoomTo(rect: makeRectFor(coords: tourCollectionOnMap.coordinates()))
    }

    private func zoomTo(rect: MKMapRect) {
        let n = CGFloat(40.0)
        let inset = UIEdgeInsets(top: n, left: n, bottom: n, right: n)
        mapView.setVisibleMapRect(rect, edgePadding: inset, animated: true)
    }

    // Show an annotation view for a place on the map
    private func showNextAnnotation(for placeOnMap: PlaceOnMap) {
        //TODO
    }
    
    private func drawOSMCopyrightNotice() {
        // bring the osm license link back to the front as it might be hidden by the map view
        self.view.bringSubview(toFront: self.osmLicenseLinkButton)
        self.osmLicenseLinkButton.setTitle("© OpenStreetMap contributors", for: .normal)
    }
}
