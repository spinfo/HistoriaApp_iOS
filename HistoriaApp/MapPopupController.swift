
import Foundation

import UIKit


class MapPopupController : UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!

    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        self.closeButton.action = #selector(self.close)
    }

    public func setPopup(byController otherViewC: UIViewController) {
        removeExistingChildViewControllers()
        setViewControllerAsPopupContent(otherViewC)
    }

    @objc public func close() {
        self.removeExistingChildViewControllers()
        MapPopupController.disconnectFromParent(self)
    }

    // MARK: -- Private methods

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
