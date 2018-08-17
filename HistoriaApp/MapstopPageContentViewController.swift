
import Foundation

import UIKit
import XCGLogger

class MapstopPageContentViewController : UIViewController {

    // Shows the main html content of the mapstop's page
    @IBOutlet weak var webView: UIWebView!

    // the page number within the range of pages for the mapstop
    private var pageIndex: Int!

    // The page to read the html content from
    private var page: Page!

    public static func instantiate(from storyboard: UIStoryboard, at idx: Int, showing page: Page) -> MapstopPageContentViewController {
        let result = storyboard.instantiateViewController(withIdentifier: "MapstopPageContentViewController") as! MapstopPageContentViewController
        result.pageIndex = idx
        result.page = page
        return result
    }

    public func index() -> Int {
        return pageIndex
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.page != nil) {
            self.webView.delegate = UIApplication.shared.delegate as! AppDelegate
            self.webView.loadHTMLString(self.page!.getPresentationContent(), baseURL: nil)
        } else {
            log.error("No page to display.")
        }
    }

}
