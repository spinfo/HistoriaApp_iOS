
import Foundation
import UIKit

class IndoorTourViewController : UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var sceneNoLabel: UILabel!
    
    var tour: Tour!

    var imageView: UIImageView!

    var stopMarkerView: UIView!

    var image: UIImage?

    var currentIndex: Int = 0

    override func viewDidLoad() {

        scrollView.delegate = self

        setTitle()
        setupSceneNoLabelBackgroundImage()
        view.bringSubview(toFront: bottomToolbar)

        loadScene(offset: currentIndex)
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
            stopMarkerView = UIView()
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
        xValue = min(scrollView.contentSize.width, (xValue + minSize.width))
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dismissCurrentIndoorTourDisplay()
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

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageHorizontallyIfTooSmall()
    }

    private func centerImageHorizontallyIfTooSmall() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsetsMake(0, offsetX, 0, 0)
    }


    private func makeToolbarTransparent() {
        bottomToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        bottomToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
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
