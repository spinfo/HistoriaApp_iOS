//
//  IndoorTourViewController.swift
//  HistoriaApp
//
//  Created by David on 27.11.18.
//

import Foundation
import UIKit

class IndoorTourViewController : UIViewController {

    var tour: Tour?

    @IBOutlet weak var scrollView: UIScrollView!

    var imageView: UIImageView?

    var image: UIImage?

    @IBOutlet weak var bottomToolbar: UIToolbar!

    override func viewDidLoad() {

        setTitle()
        view.bringSubview(toFront: bottomToolbar)

        let scene = tour!.scenes.first!

        image = getImage(for: scene)
        setupAsContent(image: image!)
        scrollToImageCenter()
    }


    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dismissCurrentIndoorTourDisplay()
    }

    private func setTitle() {
        title = tour!.name
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

    private func scrollToImageCenter() {
        let center = imageCenter()
        let size = screenOrImageFittingSize()
        let centerRect = rectFrom(center: center, size: size)
        scrollView.scrollRectToVisible(centerRect, animated: false)
    }

    private func imageCenter() -> CGPoint {
        return CGPoint(x: (image!.size.width / 2), y: (image!.size.height / 2))
    }

    // calculate a size that is the currents view bounds but not bigger than the
    // image that is currently displayed
    private func screenOrImageFittingSize() -> CGSize {
        let width = min(view.bounds.width, scrollView.contentSize.width)
        let height = min(view.bounds.height, scrollView.contentSize.height)
        return CGSize(width: width, height: height)
    }

    private func rectFrom(center: CGPoint, size: CGSize) -> CGRect {
        let origin = CGPoint(x: center.x - (size.width / 2), y: center.y - (size.height / 2))
        return CGRect(origin: origin, size: size)
    }

    private func makeToolbarTransparent() {
        bottomToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        bottomToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
}
