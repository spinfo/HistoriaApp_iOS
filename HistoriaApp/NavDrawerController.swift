
import UIKit


class NavDrawerController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let menuItems = [
        "Karte wechseln",
        " - Zur Karte",
        "Tour starten",
        "Bibliothek",
        "Magazin",
        "Über die App",
        "Impressum",
        "Datenschutz"
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
            appDelegate.switchToAreaSelection()
        case 1:
            appDelegate.switchToPlainMap()
        case 2:
            appDelegate.switchToTourSelection()
        case 3:
            appDelegate.switchToReadingMode()
        case 4:
            appDelegate.switchToCenterController("TourDownloadViewController")
        case 5:
            appDelegate.switchToAssetHtmlPage(assetName: "PageAbout", showsVersionLabel: true)
        case 6:
            appDelegate.switchToAssetHtmlPage(assetName: "PageImpressum", showsVersionLabel: false)
        case 7:
            appDelegate.switchToAssetHtmlPage(assetName: "PagePrivacyPolicy", showsVersionLabel: false)
        default:
            log.warning("Unknown menu item index: \(indexPath)")
        }

        appDelegate.closeNavDrawer()
    }

}
