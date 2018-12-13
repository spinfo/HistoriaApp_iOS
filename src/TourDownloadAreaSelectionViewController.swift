
import Foundation
import UIKit

class TourDownloadAreaSelectionViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var areaDownloadStatusList: [AreaDownloadStatus] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        self.title = "Touren laden"

        // retrieve a list of tour records from the server
        self.performUrlRequest(UrlSchemes.availableToursUri) { data in

            let recordsYaml = String(data: data, encoding: .utf8)
            guard recordsYaml != nil else {
                log.error("Unable to parse response for tour record request.")
                return
            }
            let records = ServerResponseReader.parseTourRecordsYAML(recordsYaml!)
            guard records != nil && records!.count > 0 else {
                log.error("Empty or nil response on tour record parsing.")
                return
            }
            let availableTours = AvailableTours(records!)
            // update our data and reload the table on the main thread
            DispatchQueue.main.async {
                self.areaDownloadStatusList = availableTours.buildAreaDownloadStatus()
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaDownloadStatusList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourDownloadAreaSelectionTableViewCell", for: indexPath) as! TourDownloadAreaSelectionTableViewCell

        let status = areaDownloadStatusList[indexPath.row]
        cell.idx = indexPath.row
        cell.setStatus(status)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AreaSelectionToTourDownloads") {
            let tableCell = sender as! TourDownloadAreaSelectionTableViewCell
            let controller = segue.destination as! TourDownloadViewController
            controller.tourRecords = areaDownloadStatusList[tableCell.idx].tourRecords
        }
    }

    // convenience method to perform http(s) url GET requests and deal with basic errors
    // provides the caller with a hook to just deal with the returned data
    private func performUrlRequest(_ urlString: String, dataHandler: @escaping ((Data) -> Void)) {
        guard let url = URL(string: urlString) else {
            log.error("Not a valid url: '\(urlString)'")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest) { data, response, error in
            // check for errors
            guard error == nil else {
                log.error("Error on retrieving '\(urlString)': \(error!)")
                return
            }
            // check for a 200 OK response
            let httpResponse = response as? HTTPURLResponse
            guard (httpResponse != nil && httpResponse?.statusCode == 200) else {
                log.error("Bad response on request for '\(urlString)': \(response!)")
                return
            }
            // check for a non-empty data response
            guard data != nil && data?.count != 0 else {
                log.error("Request for '\(urlString)' returned empty: \(data!)")
                return
            }
            // call the provided data handler on the data we got from the request
            dataHandler(data!)
        }
        task.resume()
    }

}


class TourDownloadAreaSelectionTableViewCell : UITableViewCell {

    let updateVersionTemplate = "Letztes Update: %@"
    let installRatioTemplate = "%d/%d installiert"
    let sizeTemplate = " (%.2f MB)"

    var idx: Int = 0

    @IBOutlet weak var areaName: UILabel!

    @IBOutlet weak var lastUpdateVersion: UILabel!

    @IBOutlet weak var installRatio: UILabel!

    func setStatus(_ status: AreaDownloadStatus) {
        areaName.text = status.name
        lastUpdateVersion.text = versionLabelText(status)
        installRatio.text = installRatioLabelText(status)
    }

    private func installRatioLabelText(_ status: AreaDownloadStatus) -> String {
        var result = String(format: installRatioTemplate, status.downloadedToursAmount, status.downloadableToursAmount)
        if (status.downloadedToursAmount > 0) {
            result += String(format: sizeTemplate, status.downloadedTourSize / 1000000)
        }
        return result
    }

    private func versionLabelText(_ status: AreaDownloadStatus) -> String {
        return String(format: updateVersionTemplate, formatDate(fromTimestamp: status.lastVersion))
    }

    private func formatDate(fromTimestamp stamp: Int) -> String {
        guard let interval = TimeInterval(exactly: stamp) else {
            log.error("Cannot format date from timestamp: \(stamp)")
            return ""
        }
        let date = Date(timeIntervalSince1970: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        return dateFormatter.string(from: date)
    }
}
