//
//  AreaSelectionViewController.swift
//  HistoriaApp
//
//  Created by David on 28.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import SpeedLog

class AreaSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var areas = Array<Area>()

    var theDao = MasterDao()

    var areaSelectionDelegate: AreaSelectionDelegate?

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // retrieve the list of areas
        self.areas = theDao.getAreas()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaSelectionTableViewCell", for: indexPath) as! AreaSelectionTableViewCell

        let area = areas[indexPath.row]
        cell.areaNameLabel.text = area.name

        let tourAmount = theDao.getTourCount(forAreaWithId: area.id)
        cell.tourAmountLabel.text = String.init(format: "Touren: %d", tourAmount)

        return cell
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let area = self.areas[indexPath.row]
        if self.areaSelectionDelegate != nil {
            areaSelectionDelegate?.areaSelected(area)
        } else {
            SpeedLog.print("ERROR", "Cannot delegate tour selection, no delegate present.")
        }
    }


}
