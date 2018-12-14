
import UIKit

import XCGLogger

class TourDownloadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tourRecords: [TourRecord]!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }
    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tourRecords.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourDownloadTableViewCell", for: indexPath) as! TourDownloadTableViewCell
        let record = tourRecords[indexPath.row]
        cell.setTourRecord(record)
        cell.setInstallStatus(MainDao().determineInstallStatus(forRecord: record))
        return cell
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TourDownloadTableViewCell else {
            log.error("Can't get cell at \(indexPath)")
            return
        }
        cell.toggleTourDownload()
    }
}
