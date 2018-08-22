
import Foundation

import UIKit

protocol MapPopupOnCloseDelegate {
    func onMapPopupClose()
}

class MapPopupController : UIViewController {

    // minimum height of the popup on sliding it in or after sliding it out
    let popupAnimationMinHeight = CGFloat(50.0)

    @IBOutlet weak var closeButton: UIBarButtonItem!

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var popupDistanceFromTop: NSLayoutConstraint!

    var closeDelegate: MapPopupOnCloseDelegate?

    private var lastParentNavigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.closeButton.action = #selector(self.close)
    }

    public func setPopup(byController otherViewC: UIViewController) {
        removeExistingChildViewControllers()
        setViewControllerAsPopupContent(otherViewC)
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        adjustPopupHeightToMinHeight()
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.23, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.adjustPopupHeightToFitBelowTopBar()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc public func close() {
        UIView.animate(withDuration: 0.23, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.adjustPopupHeightToMinHeight()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.removeSelfFromViewHierarchies()
            self.closeDelegate?.onMapPopupClose()
        })
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(in: nil, animation: nil, completion: {_ in
            self.adjustPopupHeightToFitBelowTopBar()
            self.view.layoutIfNeeded()
        })
    }

    private func adjustPopupHeightToMinHeight() {
        popupDistanceFromTop.constant = view.bounds.height - popupAnimationMinHeight
    }

    private func adjustPopupHeightToFitBelowTopBar() {
        popupDistanceFromTop.constant = determineTopBarHeight()
    }

    private func removeSelfFromViewHierarchies() {
        removeExistingChildViewControllers()
        MapPopupController.disconnectFromParent(self)
    }

    private func determineTopBarHeight() -> CGFloat {
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = lastParentNavigationController?.navigationBar.frame.height

        return statusBarHeight + (navBarHeight ?? 44.0)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if (parent?.navigationController != nil) {
            lastParentNavigationController = parent!.navigationController
        }
    }

    private func removeExistingChildViewControllers() {
        for childViewC in self.childViewControllers {
            MapPopupController.disconnectFromParent(childViewC)
        }
    }

    private static func disconnectFromParent(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

    private func setViewControllerAsPopupContent(_ viewController: UIViewController) {
        addChildViewController(viewController)
        containerView.addSubview(viewController.view!)
        viewController.didMove(toParentViewController: self)

        constrainToContainerFrame(viewController.view!)
    }

    private func constrainToContainerFrame(_ otherView: UIView) {
        otherView.translatesAutoresizingMaskIntoConstraints = false
        for direction in [NSLayoutAttribute.top, NSLayoutAttribute.right, NSLayoutAttribute.bottom, NSLayoutAttribute.left] {
            let constraint = NSLayoutConstraint(item: otherView, attribute: direction, relatedBy: .equal, toItem: self.containerView, attribute: direction, multiplier: 1.0, constant: 0.0)
            self.view.addConstraint(constraint)
        }
    }

}
