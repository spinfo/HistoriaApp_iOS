//
//  NavDrawerController.swift
//  HistoriaApp
//
//  Created by David on 11.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import SpeedLog

class NavDrawerController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let menuItems = [
        "Karte wechseln",
        "Touren wählen",
        "Lesemodus",
        "Touren laden",
        "Über uns"
    ]

    // keep references to the view controllers that we switched back from
    var previousCenterViewCs = {}

    var currentMenuItem = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: -- UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NavDrawerTableViewCell", for: indexPath) as! NavDrawerTableViewCell
        cell.menuItemLabel.text = menuItems[indexPath.row]
        return cell
    }

    // MARK: -- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        switch indexPath.row {
        case 0:
            appDelegate.switchToCenterController("MapViewController")
        case 2:
            appDelegate.switchToCenterController("ReadingModeViewController")
        case 3:
            appDelegate.switchToCenterController("TourDownloadViewController")

        default:
            SpeedLog.print("Tapped: \(indexPath)")
        }

        // if everything wen
    }

}
