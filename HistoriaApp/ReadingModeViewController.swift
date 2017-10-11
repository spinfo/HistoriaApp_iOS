//
//  ReadingModeViewController.swift
//  HistoriaApp
//
//  Created by David on 12.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class ReadingModeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Lesemodus"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.toggleNavDrawer()
    }

}
