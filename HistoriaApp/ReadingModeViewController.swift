
import UIKit

class ReadingModeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Lesemodus"
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
