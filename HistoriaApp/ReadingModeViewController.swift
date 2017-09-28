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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.toggleNavDrawer()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
