
import UIKit

import XCGLogger

protocol CurrentAreaProvider {
    func getCurrentArea() -> Area
}

class TourSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tours = Array<Tour>()

    var tourSelectionDelegate: TourSelectionDelegate?

    var areaProvider: CurrentAreaProvider?

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshTours()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // we may be told from the outside to refresh our content
    func refreshTours() {
        guard areaProvider != nil else {
            log.error("Cannot determine area in which to select tours")
            return
        }

        let dao = MainDao()
        let area = areaProvider!.getCurrentArea()

        self.tours = dao.getTours(inAreaWIthId: area.id)
        if (tableView != nil) {
            tableView.reloadData()
        }

        log.info("Refreshed tour list to display: Have \(tours.count) tours in \(area.name)")
    }


    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourSelectionTableViewCell", for: indexPath) as! TourSelectionTableViewCell

        let tour = tours[indexPath.row]
        cell.setTour(tour)

        cell.layoutIfNeeded()

        return cell
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tour = self.tours[indexPath.row]
        if self.tourSelectionDelegate != nil {
            tourSelectionDelegate?.tourSelectedForPreview(tour)
        } else {
            log.error("Cannot delegate tour selection, no delegate present.")
        }
    }



}
