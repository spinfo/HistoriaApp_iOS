
import Foundation
import UIKit

class MapstopPageViewController : UIPageViewController, UIPageViewControllerDataSource {

    var mapstop: Mapstop?

    private var pages: [Page]?

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchPages()

        self.dataSource = self

        if !(self.pages!.isEmpty) {
            let startingViewController = newMapstopPageContentViewController(at: 0)
            setViewControllers([startingViewController!], direction: .forward, animated: false, completion: nil)
        }
    }

    private func fetchPages() {
        guard mapstop != nil else {
            log.error("Mapstop page view controller has no mapstop set.")
            pages = Array()
            return
        }
        self.pages = MainDao().getPages(forMapstop: mapstop!.id)
    }

    // -- MARK: UIPageVieControllerDataSource

    // prepare the mastops page before the current one
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! MapstopPageContentViewController
        return self.newMapstopPageContentViewController(at: controller.index() - 1)
    }

    // prepare the mastops page after the current one
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! MapstopPageContentViewController
        return self.newMapstopPageContentViewController(at: controller.index() + 1)
    }

    private func newMapstopPageContentViewController(at idx: Int) -> MapstopPageContentViewController? {
        guard isInPagesBounds(idx) else {
            return nil
        }
        return MapstopPageContentViewController.instantiate(from: self.storyboard!, at: idx, showing: pages![idx])
    }

    private func isInPagesBounds(_ i: Int) -> Bool {
        return i >= 0 && i < pages!.count
    }

    // tell the caller how many pages the currently selected mapstop has
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pages!.count
    }

    // tell the caller that we always start at the first mapstop page
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
