
import Foundation

import UIKit


class MapPopupController : UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!

    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        self.closeButton.action = #selector(self.close)
    }

    public func setPopup(byController otherViewC: UIViewController) {

        self.removeExistingChildViews()

        self.addChildViewController(otherViewC)
        self.containerView.addSubview(otherViewC.view!)

        // dynamically add constraints such that the controller's view will fit the popup
        otherViewC.view.translatesAutoresizingMaskIntoConstraints = false
        for direction in [NSLayoutAttribute.top, NSLayoutAttribute.right, NSLayoutAttribute.bottom, NSLayoutAttribute.left] {
            let constraint = NSLayoutConstraint(item: otherViewC.view, attribute: direction, relatedBy: .equal, toItem: self.containerView, attribute: direction, multiplier: 1.0, constant: 0.0)
            self.view.addConstraint(constraint)
        }

        // signal to the other view controller where it is now
        otherViewC.didMove(toParentViewController: self)
    }

    @objc public func close() {
        self.removeExistingChildViews()
        self.removeViewController(self)
    }

    // MARK: -- Private methods

    private func userRequestedRemoval(sender: UIBarButtonItem) {
        self.close()
    }

    private func removeExistingChildViews() {
        for childViewC in self.childViewControllers {
            self.removeViewController(childViewC)
        }
    }

    // convenience method to un-connect a view controller from it's parent
    private func removeViewController(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

}
