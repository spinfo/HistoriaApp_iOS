
import UIKit

import XCGLogger

class TourSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tours = Array<Tour>()

    var tourSelectionDelegate: TourSelectionDelegate?

    var areaProvider: AreaProvider?

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshTours()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshTours() {
        fetchToursInCurrentArea()
        tableView?.reloadData()
    }

    private func fetchToursInCurrentArea() {
        guard areaProvider != nil else {
            log.error("Cannot determine area in which to select tours")
            return
        }
        let area = areaProvider!.getCurrentArea()

        let dao = MainDao()
        self.tours = dao.getTours(inAreaWIthId: area.id)
        log.info("Refreshed tour list to display: Have \(tours.count) tours in \(area.name)")
    }


    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourSelectionTableViewCell", for: indexPath) as! TourSelectionTableViewCell

        cell.setTour(tourAt(indexPath))

        cell.layoutIfNeeded()

        return cell
    }

    private func tourAt(_ indexPath: IndexPath) -> Tour {
        return tours[indexPath.row]
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tour = tourAt(indexPath)
        if self.tourSelectionDelegate != nil {
            tourSelectionDelegate?.tourSelectedForPreview(tour)
        } else {
            log.error("Cannot delegate tour selection, no delegate present.")
        }
    }

}
