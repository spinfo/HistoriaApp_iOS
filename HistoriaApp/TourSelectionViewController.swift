//
//  TourSelectionViewController.swift
//  HistoriaApp
//
//  Created by David on 19.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import SpeedLog

class TourSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tours = Array<Tour>()

    var tourSelectionDelegate: TourSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let dao = MasterDao()
        let area = dao.getFirstArea()!
        guard let tours = dao.getTours(inAreaWIthId: area.id) else {
            SpeedLog.print("ERROR", "Cannot show tour selection without tours in area.")
            return
        }
        self.tours = tours
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
