
import UIKit

class ReadingModeTabBarController: UITabBarController, UITabBarControllerDelegate, ReadingModeBackButtonDisplay {

    @IBOutlet var toolbarBackButton: UIBarButtonItem!

    var areaProvider: AreaProvider!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.title = "Bibliothek"

        let tourViewC = self.viewControllers?.first as! ReadingModeToursNavigationController
        tourViewC.areaProvider = self.areaProvider
        tourViewC.backButtonDisplay = self

        self.hideBackButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.toggleNavDrawer()
    }

    @IBAction func rightBarButtonItemTapped(_ sender: Any) {
        guard selectedViewController is ReadingModeBackButtonUser else {
            return
        }
        let user = selectedViewController as! ReadingModeBackButtonUser
        user.backButtonPressed()
    }

    // -- ReadingModeBackButtonDisplay

    func showBackButton() {
        if (!rightBarButtonItemIsSet()) {
            navigationItem.setRightBarButtonItems([toolbarBackButton], animated: true)
        }
    }

    func hideBackButton() {
        navigationItem.rightBarButtonItem = nil
    }

    private func rightBarButtonItemIsSet() -> Bool {
        let items = navigationItem.rightBarButtonItems
        return (items != nil && !(items!.isEmpty))
    }

}



