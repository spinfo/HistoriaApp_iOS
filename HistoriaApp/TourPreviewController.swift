
import Foundation
import UIKit

class TourPreviewController : UIViewController {

    var tour: Tour?

    var tourSelectionDelegate: TourSelectionDelegate?

    @IBOutlet weak var tourShortInfoView: TourShortInfoView!

    @IBOutlet weak var tourIntroduction: UILabel!

    @IBOutlet weak var tourStopList: UILabel!

    @IBOutlet weak var tourAuthorAttribution: UILabel!

    @IBOutlet weak var scrollview: UIScrollView!

    override func viewDidLoad() {
        log.debug("Tour selected for debug: \(String(describing: tour?.id))")

        guard tour != nil else {
            log.error("No tour available for display.")
            return
        }
        updateContent(using: tour!)
    }

    private func updateContent(using tour: Tour) {
        tourShortInfoView.updateContent(using: tour)
        tourIntroduction.text = tour.intro
        tourAuthorAttribution.text = generateAuthorAttributionText(tour)
        tourStopList.text = generateTourStopListText(tour)
    }

    private func generateAuthorAttributionText(_ tour: Tour) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return String(format: "Von: %@, %@", tour.author, formatter.string(from: tour.createdAt))
    }

    private func generateTourStopListText(_ tour: Tour) -> String {
        var result = ""
        var i = 1
        for mapstop in tour.mapstops {
            result += String(format: "%d. %@\n", i, mapstop.name)
            i += 1
        }
        return result
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tourSelectionDelegate?.tourPreviewAborted()
    }

    @IBAction func okButtonTapped(_ sender: Any) {
        self.tourSelectionDelegate?.tourSelected(tour!)
    }



}
