
import Foundation
import UIKit

class ReadingModeMapstopPageViewController : UIViewController, ReadingModeBackButtonUser {

    var backButtonDisplay: ReadingModeBackButtonDisplay?

    var mapstop: Mapstop!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButtonDisplay?.showBackButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backButtonDisplay?.hideBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "embedMapstopPageViewSegue" == segue.identifier {
            let embeddedController = segue.destination as! MapstopPageViewController
            embeddedController.mapstop = mapstop
        }
    }

    func backButtonPressed() {
        return
    }

}
