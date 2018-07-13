
import UIKit

class AboutPageViewController: UIViewController {

    @IBOutlet weak var versionNoLabel: UIBarButtonItem!

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "HistoriaApp"

        // setup the about page to load and the app delegate to handle link clicks etc.
        self.webView.delegate = UIApplication.shared.delegate as! AppDelegate
        self.webView.loadHTMLString(self.getAboutPageContent(), baseURL: nil)

        // get and display the apps current version
        guard let versionStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            self.versionNoLabel.title = ""
            return
        }
        self.versionNoLabel.title = "Version \(versionStr)"
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
            log.error("About page asset data not present.")
            return ""
        }
        guard let aboutPageHtml = String(data: asset.data, encoding: .utf8) else {
            log.error("Cannot parse about page asset data into string.")
            return ""
        }
        return aboutPageHtml
    }
}
