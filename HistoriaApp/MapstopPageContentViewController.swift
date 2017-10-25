
import Foundation

import UIKit
import SpeedLog

class MapstopPageContentViewController : UIViewController {

    //MARK: Properties

    // Shows the main html content of the mapstop's page
    @IBOutlet weak var webView: UIWebView!

    // the page number within the range of pages for the mapstop
    public var pageIndex: Int?

    // The page to read the html content from
    public var page: Page?

    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.page != nil) {
            self.webView.delegate = UIApplication.shared.delegate as! AppDelegate
            self.webView.loadHTMLString(self.page!.getPresentationContent(), baseURL: nil)
        } else {
            SpeedLog.print("ERROR", "No page to display.")
        }
    }

}
