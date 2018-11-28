//
//  IndoorTourViewController.swift
//  HistoriaApp
//
//  Created by David on 27.11.18.
//

import Foundation
import UIKit

class IndoorTourViewController : UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!

    var tour: Tour?

    var imageView: UIImageView?

    var image: UIImage?

    var currentIndex: Int = 0

    override func viewDidLoad() {

        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 5.0

        setTitle()
        view.bringSubview(toFront: bottomToolbar)

        loadScene(offset: currentIndex)
    }

    private func setTitle() {
        title = tour!.name
    }

    private func loadScene(offset: Int) {
        let index = currentIndex + offset
        guard index >= 0 && index < tour!.scenes.count else {
            return
        }
        let scene = tour!.scenes[index]

        image = getImage(for: scene)
        setupAsContent(image: image!)
        zoomToFitImageHeightInCenter()

        currentIndex = index
        conditionallyHideToolbarButtons()
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
        let center = imageCenter()
        let height = max(scrollView.bounds.height, image!.size.height)
        let size = CGSize(width: scrollView.bounds.width - 1, height: height - 1)
        let fittingRect = rectFrom(center: center, size: size)
        scrollView.zoom(to: fittingRect, animated: false)
    }

    private func imageCenter() -> CGPoint {
        return CGPoint(x: (image!.size.width / 2), y: (image!.size.height / 2))
    }

    private func rectFrom(center: CGPoint, size: CGSize) -> CGRect {
        let origin = CGPoint(x: center.x - (size.width / 2), y: center.y - (size.height / 2))
        return CGRect(origin: origin, size: size)
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

    private func makeToolbarTransparent() {
        bottomToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        bottomToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
}
