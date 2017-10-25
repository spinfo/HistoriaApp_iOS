
import UIKit

import SpeedLog

class TourSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tours = Array<Tour>()

    var tourSelectionDelegate: TourSelectionDelegate?

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
        let dao = MasterDao()
        // TODO: This has to react to the currently chosen area
        let area = dao.getFirstArea()!
        self.tours = dao.getTours(inAreaWIthId: area.id)
        SpeedLog.print("INFO", "Refreshed tour list to display: Have \(tours.count) tours")
    }


    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourSelectionTableViewCell", for: indexPath) as! TourSelectionTableViewCell

        let tour = tours[indexPath.row]
        cell.setTour(tour)
        return cell
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tour = self.tours[indexPath.row]
        if self.tourSelectionDelegate != nil {
            tourSelectionDelegate?.tourSelected(tour)
        } else {
            SpeedLog.print("ERROR", "Cannot delegate tour selection, no delegate present.")
        }
    }



}
