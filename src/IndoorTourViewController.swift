
import Foundation
import UIKit

// A view class that passes all touch events to the views underneath
class PassthroughView : UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

protocol IndoorTourProvider {
    func getTour() -> Tour
}

class IndoorTourViewController : UIViewController, UIScrollViewDelegate, MapPopupOnCloseDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var sceneNoLabel: UILabel!
    @IBOutlet weak var swipeHintContainerView: PassthroughView!
    
    var imageView: UIImageView!
    var stopMarkerView: UIView!
    var image: UIImage?

    private var mapPopupController: MapPopupController?

    private var tour: Tour!

    var tourProvider: IndoorTourProvider!

    private var currentIndex: Int = 0

    private var shouldShowSwipeHint = true

    override func viewDidLoad() {
        scrollView.delegate = self
        view.bringSubview(toFront: bottomToolbar)

        // only on first controller start show the user a hint that the he can scroll through the scene
        swipeHintContainerView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.swipeHintContainerView.isHidden = true
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (tour == nil || tourProvider.getTour().id != tour.id) {
            tour = tourProvider.getTour()
            currentIndex = 0
            setTitle()
            setupSceneNoLabelBackgroundImage()
            loadScene(offset: currentIndex)
        }
    }

    private func setTitle() {
        title = tour!.name
    }

    private func setupSceneNoLabelBackgroundImage() {
        let image = #imageLiteral(resourceName: "SceneNoSquareBackground")
        sceneNoLabel.backgroundColor = UIColor(patternImage: image.imageResize(sizeChange: sceneNoLabel.frame.size))
    }

    private func loadScene(offset: Int) {
        let index = currentIndex + offset
        guard index >= 0 && index < tour!.scenes.count else {
            return
        }
        let scene = tour!.scenes[index]

        cleanupViews()

        image = getImage(for: scene)
        setupAsContent(image: image!)
        zoomToFitImageHeightInCenter()
        setupStopMarkerView(for: scene)

        currentIndex = index
        conditionallyHideToolbarButtons()
        setSceneNoLabelCount()
        centerImageIfTooSmall()
    }

    private func cleanupViews() {
        if (imageView != nil) {
            imageView.removeFromSuperview()
            imageView = nil
        }
        if (stopMarkerView != nil) {
            stopMarkerView.removeFromSuperview()
            stopMarkerView = nil
        }
    }

    private func getImage(for scene: Scene) -> UIImage {
        guard let url = FileService.getFile(atBase: scene.src) else {
            log.error("Unable to determine valid image url for: \(scene.src)")
            return UIImage()
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            log.error("No file at: \(url.path)")
            return UIImage()
        }
        return UIImage(contentsOfFile: url.path)!
    }

    private func setupAsContent(image: UIImage) {
        imageView?.removeFromSuperview()

        imageView = UIImageView(image: image)
        scrollView.insertSubview(imageView!, at: 0)
        scrollView.contentSize = image.size
    }

    private func zoomToFitImageHeightInCenter() {
        let height = max(scrollView.bounds.height, image!.size.height)
        let size = CGSize(width: scrollView.bounds.width, height: height)
        let fittingRect = CGRect(origin: .zero, size: size)
        zoomOnceFixingTheNewZoomScale(to: fittingRect)
    }

    private func zoomOnceFixingTheNewZoomScale(to rect: CGRect) {
        scrollView.minimumZoomScale = CGFloat.leastNonzeroMagnitude
        scrollView.maximumZoomScale = CGFloat.greatestFiniteMagnitude
        scrollView.zoom(to: rect, animated: false)
        scrollView.minimumZoomScale =  scrollView.zoomScale
        scrollView.maximumZoomScale = scrollView.zoomScale
    }

    private func conditionallyHideToolbarButtons() {
        previousButton.isEnabled = true
        nextButton.isEnabled = true
        if (currentIndex == 0) {
            previousButton.isEnabled = false
        } else if (currentIndex == (tour!.scenes.count - 1)) {
            nextButton.isEnabled = false
        }
    }

    private func setSceneNoLabelCount() {
        sceneNoLabel.text = String(format: "%d\n%d", (currentIndex + 1), tour.scenes.count)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.loadScene(offset: 0)
        }, completion: nil)
    }

    // MARK: Positioning Mapstop Markers

    private func setupStopMarkerView(for scene: Scene) {
        if (stopMarkerView == nil) {
            stopMarkerView = UIView(frame: CGRect(origin: view.frame.origin, size: scrollView.contentSize))
        }
        scrollView.addSubview(stopMarkerView)
        scrollView.bringSubview(toFront: stopMarkerView)

        var scrolled = false
        for stop in scene.mapstops {
            let markerView = buildStopMarkerView(for: stop)
            stopMarkerView.addSubview(markerView)

            if (!scrolled) {
                scrollRightAndCenterOn(x: (markerView.frame.origin.x + (markerView.frame.size.width / 2) ))
                scrolled = true
            }
        }
    }

    private func scrollRightAndCenterOn(x: CGFloat) {
        let minSize = CGSize(width: 1, height: 1)
        var xValue = x + (view.frame.size.width / 2)
        xValue = min(scrollView.contentSize.width - minSize.width, (xValue + minSize.width))
        let point = CGPoint(x: xValue, y: 1)
        scrollView.scrollRectToVisible(CGRect(origin: point, size: minSize), animated: false)
    }

    private func buildStopMarkerView(for stop: Mapstop) -> UIView {
        let size = CGSize(width: 40, height: 40)
        let point = deriveStopPosition(stop, markerSize: size)
        let label = UILabel(frame: CGRect(origin: point, size: size))

        let image: UIImage
        if (stop.sceneType == "info") {
            image = #imageLiteral(resourceName: "StopMarkerWhite")
            label.textColor = .black
        } else {
            image = #imageLiteral(resourceName: "StopMarkerBlue")
            label.textColor = .white
        }

        label.backgroundColor = UIColor(patternImage: image.imageResize(sizeChange: size))
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.text = String(stop.pos)
        setupCallback(showing: stop, byTappingOn: label)
        return label
    }

    private func deriveStopPosition(_ stop: Mapstop, markerSize: CGSize) -> CGPoint {
        guard let coord = stop.sceneCoordinate else {
            log.warning("Mapstop without coordinate: \(stop.name)")
            return CGPoint()
        }
        let point = coord.positionOnSurface(withSize: scrollView.contentSize)
        return CGPoint(x: point.x - markerSize.width, y: point.y - markerSize.height)
    }

    // MARK: Buttons

    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        let closeDialog = buildTourCloseDialog()
        self.present(closeDialog, animated: true, completion: nil)
    }

    private func buildTourCloseDialog() -> UIAlertController {
        let title = "Tour verlassen"
        let message = "Wollen Sie die Tour wirklich verlassen?"
        let closeDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        closeDialog.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.dismissCurrentIndoorTourDisplay()
        }))
        closeDialog.addAction(UIAlertAction(title: "Abbrechen", style: .default, handler: nil))
        return closeDialog
    }

    @IBAction func previousButtonTapped(_ sender: Any) {
        loadScene(offset: -1)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        loadScene(offset: 1)
    }

    // MARK: UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    private func centerImageIfTooSmall() {
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
    }

    // MARK: -- popups

    class TapOnMapstopMarkerGestureRecognizer : UITapGestureRecognizer {
        var mapstop: Mapstop?
    }

    private func setupCallback(showing stop: Mapstop, byTappingOn view: UIView) {
        view.isUserInteractionEnabled = true
        let tap = TapOnMapstopMarkerGestureRecognizer(target: self, action: #selector(stopMarkerSelected(_:)))
        tap.mapstop = stop
        view.addGestureRecognizer(tap)
    }

    @objc func stopMarkerSelected(_ sender: UITapGestureRecognizer) {
        guard let stopSender = sender as? TapOnMapstopMarkerGestureRecognizer else {
            return
        }
        mapstopSelected(stopSender.mapstop!)
    }

    func mapstopSelected(_ mapstop: Mapstop) {
        let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapstopPageViewController") as? MapstopPageViewController
        pageViewController!.mapstop = mapstop
        self.displayAsPopup(controller: pageViewController!)
    }

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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mapPopupController?.viewWillTransition(to: size, with: coordinator)
    }
}



fileprivate extension UIImage {

    func imageResize (sizeChange:CGSize)-> UIImage{

        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }

}
