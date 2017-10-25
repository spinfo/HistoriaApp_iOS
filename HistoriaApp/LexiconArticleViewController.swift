
import UIKit

import SpeedLog

protocol LexiconArticleCloseDelegate {
    func onCloseLexiconArticle() -> Void
}

class LexiconArticleViewController: UIViewController {

    var lexiconEntry: LexiconEntry?

    var delegate: LexiconArticleCloseDelegate?

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Lexikon"

        if self.lexiconEntry != nil {
            self.webView.delegate = UIApplication.shared.delegate as! AppDelegate
            self.webView.loadHTMLString(lexiconEntry!.getPresentationContent(), baseURL: nil)
        } else {
            SpeedLog.print("ERROR", "No lexicon entry defined for article view.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.delegate?.onCloseLexiconArticle()
    }

    @IBAction func leftBarButtonItemTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleNavDrawer()
    }
}
