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

    let mockTourRecords = [ TourRecord(), TourRecord() ]

    override func viewDidLoad() {
        super.viewDidLoad()

        mockTourRecords[0].name = "Mock Tour 1"
        mockTourRecords[0].areaName = "Düsseldorf"
        mockTourRecords[0].downloadSize = 3450982374

        mockTourRecords[1].name = "Mock Tour 2"
        mockTourRecords[1].areaName = "Düsseldorf"
        mockTourRecords[1].downloadSize = 3450982374
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockTourRecords.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourDownloadTableViewCell", for: indexPath) as! TourDownloadTableViewCell

        let record = mockTourRecords[indexPath.row]
        cell.tourName.text = record.name
        cell.areaName.text = record.areaName
        cell.progress.text = "(ca. \(record.downloadSize / 1000000) MB)"
        return cell
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let record = mockTourRecords[indexPath.row]

        SpeedLog.print("Requested tour download: \(record.name)")

    }

}
