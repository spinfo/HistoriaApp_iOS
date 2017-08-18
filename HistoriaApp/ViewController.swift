//
//  ViewController.swift
//  HistoriaApp
//
//  Created by David on 10.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import GRDB

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // use the file service to install the example data
        if FileService.installExampleTour() {
            print("Examples installed.")
        } else {
            print("Error installing examples.")
        }
        
        // try to set up a database
        // TODO: remove the test code
        do {
            let dbFile = FileService.getDBFile()!
            let dbQueue = try DatabaseQueue(path: dbFile.path)
            
            print(dbQueue.configuration)
        } catch {
            print("Failed to set up database: \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

