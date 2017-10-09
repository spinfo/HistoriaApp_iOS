//
//  AboutPageViewController.swift
//  HistoriaApp
//
//  Created by David on 09.10.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import SpeedLog

class AboutPageViewController: UIViewController {

    @IBOutlet weak var versionNoLabel: UIBarButtonItem!

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.loadHTMLString(self.getAboutPageContent(), baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }


    // -- MARK: Private methods

    private func getAboutPageContent() -> String {
        // retrieve the asset data as a string
        guard let asset = NSDataAsset(name: "AboutPage") else {
            SpeedLog.print("ERROR", "About page asset data not present.")
            return ""
        }
        guard let aboutPageHtml = String(data: asset.data, encoding: .utf8) else {
            SpeedLog.print("ERROR", "Cannot parse about page asset data into string.")
            return ""
        }
        return aboutPageHtml
    }
}
