
import Foundation
import UIKit

class ReadingModeToursNavigationController : UINavigationController, TourSelectionDelegate, MapstopSelectionDelegate, ReadingModeBackButtonUser {
    
    var backButtonDisplay: ReadingModeBackButtonDisplay?

    var areaProvider: AreaProvider!

    private var selectedTour: Tour?

    private var selectedMapstop: Mapstop?

    override func viewDidLoad() {
        super.viewDidLoad()

        let controller = childViewControllers.first as! TourSelectionViewController
        prepareDependenciesOnChildController(controller)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "mapstopListSegue" == segue.identifier {
            let controller = segue.destination as! ReadingModeMapstopListController
            prepareDependenciesOnChildController(controller)
        }
        else if "showMapstopPagesInReadingModeSegue" == segue.identifier {
            let controller = segue.destination as! ReadingModeMapstopPageViewController
            prepareDependenciesOnChildController(controller)
        }
    }

    private func prepareDependenciesOnChildController(_ controller: TourSelectionViewController) {
        controller.areaProvider = self.areaProvider
        controller.tourSelectionDelegate = self
    }

    private func prepareDependenciesOnChildController(_ controller: ReadingModeMapstopPageViewController) {
        controller.backButtonDisplay = self.backButtonDisplay
        controller.mapstop = selectedMapstop
    }

    private func prepareDependenciesOnChildController(_ controller: ReadingModeMapstopListController) {
        controller.backButtonDisplay = self.backButtonDisplay
        controller.mapstopSelectionDelegate = self
        controller.mapstops = fetchMapstops(for: selectedTour)
    }


    private func fetchMapstops(for tour: Tour?) -> [Mapstop] {
        guard tour != nil else {
            log.warning("Not fetching stops for nil tour.")
            return Array()
        }
        return MainDao().getMapstops(forTour: tour!.id)
    }

    // -- MARK: Model selection

    func tourSelectedForPreview(_ tour: Tour) {
        selectedTour = tour
        performSegue(withIdentifier: "mapstopListSegue", sender: self)
    }

    func tourSelected(_ tour: Tour) {
        return
    }

    func tourPreviewAborted() {
        return
    }

    func mapstopSelected(_ mapstop: Mapstop) {
        selectedMapstop = mapstop
        performSegue(withIdentifier: "showMapstopPagesInReadingModeSegue", sender: self)
    }

    // -- ReadingModeBackButtonUser

    func backButtonPressed() {
        popMapstopListControllerIfItIsTheRightType()
    }

    private func popMapstopListControllerIfItIsTheRightType() {
        if (topViewController is ReadingModeMapstopListController || topViewController is ReadingModeMapstopPageViewController) {
            popViewController(animated: true)
        }
    }

}
