
import Foundation
import UIKit

class AssetHtmlWebViewController: UIViewController {

    @IBOutlet weak var versionNoLabel: UIBarButtonItem!

    @IBOutlet weak var webView: UIWebView!

    var assetName = ""

    var showsVersionLabel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "HistoriaApp"
        self.webView.delegate = UIApplication.shared.delegate as! AppDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.webView.loadHTMLString(FileService.getAssetFile(assetName), baseURL: nil)

        if (showsVersionLabel) {
            displayVersionLabel()
        } else {
            hideVersionLabel()
        }
    }

    private func displayVersionLabel() {
        guard let versionStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            hideVersionLabel()
            return
        }
        self.versionNoLabel.title = "Version \(versionStr)"
    }

    private func hideVersionLabel() {
        self.versionNoLabel.title = ""
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
