
import UIKit

import XCGLogger

class TourDownloadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tourRecords = Array<TourRecord>()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

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
            // update our data and reload the table on the main thread
            DispatchQueue.main.async {
                self.tourRecords = records!
                self.tableView.reloadData()
            }
        }

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

    // MARK: -- Private methods

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
                log.error("Error on retrieving '\(urlString)': \(error)")
                return
            }
            // check for a 200 OK response
            let httpResponse = response as? HTTPURLResponse
            guard (httpResponse != nil && httpResponse?.statusCode == 200) else {
                log.error("Bad response on request for '\(urlString)': \(response)")
                return
            }
            // check for a non-empty data response
            guard data != nil && data?.count != 0 else {
                log.error("Request for '\(urlString)' returned empty: \(data)")
                return
            }
            // call the provided data handler on the data we got from the request
            dataHandler(data!)
        }
        task.resume()
    }

}
