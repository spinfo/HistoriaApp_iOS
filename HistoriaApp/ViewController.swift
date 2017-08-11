//
//  ViewController.swift
//  HistoriaApp
//
//  Created by David on 10.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // use the file service to install the example data
        if FileService.installExampleTour() {
            print("Examples installed.")
        } else {
            print("Error installing examples.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

