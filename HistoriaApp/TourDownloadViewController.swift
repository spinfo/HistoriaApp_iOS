//
//  TourDownloadViewController.swift
//  HistoriaApp
//
//  Created by David on 13.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import SpeedLog

class TourDownloadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let recordsEndpoint = "https://historia-app.de/wp-content/uploads/smart-history-tours/tours.yaml"

    private var tourRecords = Array<TourRecord>()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // retrieve a list of tour records from the server
        self.performUrlRequest(self.recordsEndpoint) { data in

            let recordsYaml = String(data: data, encoding: .utf8)
            guard recordsYaml != nil else {
                SpeedLog.print("ERROR", "Unable to parse response for tour record request.")
                return
            }
            let records = ServerResponseReader.parseTourRecordsYAML(recordsYaml!)
            guard records != nil && records!.count > 0 else {
                SpeedLog.print("ERROR", "Empty or nil response on tour record parsing.")
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

    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tourRecords.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourDownloadTableViewCell", for: indexPath) as! TourDownloadTableViewCell

        let record = tourRecords[indexPath.row]
        cell.tourName.text = record.name
        cell.areaName.text = record.areaName
        cell.progress.text = "(ca. \(record.downloadSize / 1000000) MB)"
        return cell
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let record = tourRecords[indexPath.row]

        SpeedLog.print("Requested tour download: \(record.name)")

    }

    // MARK: -- Private methods

    // convenience method to perform http(s) url GET requests and deal with basic errors
    // provides the caller with a hook to just deal with the returned data
    private func performUrlRequest(_ urlString: String, dataHandler: @escaping ((Data) -> Void)) {
        guard let url = URL(string: urlString) else {
            SpeedLog.print("ERROR", "Not a valid url: '\(urlString)'")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            // check for errors
            guard error == nil else {
                SpeedLog.print("ERROR", "Error on retrieving '\(urlString)': \(error)")
                return
            }
            // check for a 200 OK response
            let httpResponse = response as? HTTPURLResponse
            guard (httpResponse != nil && httpResponse?.statusCode == 200) else {
                SpeedLog.print("ERROR", "Bad response on request for '\(urlString)': \(response)")
                return
            }
            // check for a non-empty data response
            guard data != nil && data?.count != 0 else {
                SpeedLog.print("ERROR", "Request for '\(urlString)' returned empty: \(data)")
                return
            }
            // call the provided data handler on the data we got from the request
            dataHandler(data!)
        }
        task.resume()
    }

}
