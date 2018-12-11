
import UIKit

import XCGLogger
import MMDrawerController

// globally declare the logger
let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWebViewDelegate, LexiconArticleCloseDelegate {
    
    // MARK: Properties for Navigation

    private var centerContainer: MMDrawerController?

    private let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

    private var centerViewControllers = Dictionary<String, UIViewController>()

    private var currentCenterController: UIViewController?

    private var lexiconDisplayControllerStack = Array<UIViewController>()

    // MARK: Normal AppDelegate stuff

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Set logging options for the app
        // TODO: Set log level to .error in production
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)

        // Set the appearence of page view indicators
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        pageControl.backgroundColor = UIColor.white

        // setup the Main container with navigation and the map as first view
        self.centerContainer = setupCenterContainer()
        self.switchToCenterController("MapViewController")
        window!.rootViewController = self.centerContainer
        window!.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // -- MARK: Navigation

    // a controller may request to be put in center view and will be so put, if it isn't there already
    func requestCenter(for controller: UIViewController) {
        if (self.currentCenterController != nil && self.currentCenterController! == controller) {
            log.info("Controller \(type(of: controller)) already in center.")
            return
        }
        // if we are not switching to a lexicon article, discard the lexicon article stack
        if !((controller as? LexiconArticleViewController) != nil) {
            self.lexiconDisplayControllerStack.removeAll()
        }

        // setup the new center controller and correctly linkt it to the navigation drawer
        let centerNavC = UINavigationController(rootViewController: controller)
        self.centerContainer?.centerViewController = centerNavC
        self.centerContainer?.closeDrawer(animated: true, completion: nil)
        self.currentCenterController = controller
    }

    func switchToCenterController(_ identifier: String) {
        switchToCenterController(getCenterController(identifier))
    }

    func switchToCenterController(_ viewController: UIViewController) {
        self.requestCenter(for: viewController)
    }

    func switchToTourSelection() {
        // link tour selection and map view controller
        let tourSelectionC = self.getCenterController("TourSelectionViewController") as! TourSelectionViewController
        let mapViewC = self.getCenterController("MapViewController") as! MapViewController
        tourSelectionC.tourSelectionDelegate = mapViewC
        tourSelectionC.areaProvider = mapViewC
        tourSelectionC.refreshTours()

        self.switchToMapPopup(with: tourSelectionC)
    }

    func switchToAreaSelection() {
        // link area selection and map view controller
        let areaSelectionC = self.getCenterController("AreaSelectionViewController") as! AreaSelectionViewController
        let mapViewC = self.getCenterController("MapViewController") as! MapViewController
        areaSelectionC.areaSelectionDelegate = mapViewC

        // tell the controller to refresh the content
        areaSelectionC.refreshAreas()

        // display the area selection as a popup on the map
        self.switchToMapPopup(with: areaSelectionC)
    }

    func switchToPlainMap() {
        let mapViewC = self.getCenterController("MapViewController") as! MapViewController
        switchToCenterController(mapViewC)
        mapViewC.closePopups()
    }

    func switchToReadingMode() {
        let readingModeViewC = getCenterController("ReadingModeTabBarController") as! ReadingModeTabBarController
        readingModeViewC.areaProvider = self.getCenterController("MapViewController") as! MapViewController
        switchToCenterController(readingModeViewC)
    }

    func switchToAssetHtmlPage(assetName: String, showsVersionLabel: Bool) {
        let assetHtmlViewC = instantiateCenterController("AssetHtmlWebViewController") as! AssetHtmlWebViewController
        assetHtmlViewC.assetName = assetName
        assetHtmlViewC.showsVersionLabel = showsVersionLabel
        switchToCenterController(assetHtmlViewC)
    }

    func toggleNavDrawer() {
        centerContainer?.toggle(.left, animated: true, completion: nil)
    }

    func closeNavDrawer() {
        self.centerContainer?.closeDrawer(animated: true, completion: nil)
    }

    // since lexicon articles can lead to further lexicon articles, switching to one starts a
    // view controller stack, where the first element is the current center view controller
    // and further lexicon entries may be added to it
    func switchToLexiconArticle(for entry: LexiconEntry) {
        let entryC = self.mainStoryboard.instantiateViewController(withIdentifier: "LexiconArticleViewController") as! LexiconArticleViewController
        entryC.lexiconEntry = entry
        entryC.delegate = self

        // a lexicon article is added from another view, add that controller to the stack as first elem
        if (self.lexiconDisplayControllerStack.count == 0) {
            self.lexiconDisplayControllerStack.append(self.currentCenterController!)
        }

        // add the lexicon entry controller to the stack and display it in the center
        self.lexiconDisplayControllerStack.append(entryC)
        self.requestCenter(for: entryC)
    }


    // -- MARK: UIWebViewDelegate

    // url requests made from within a web view of this app should be handled globally
    // by this method

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        let urlScheme = request.mainDocumentURL?.scheme
        guard urlScheme != nil else {
            // Never load anything that we can't know the scheme of
            log.warning("No url scheme for request: \(request)")
            return false
        }

        if navigationType == .linkClicked {
            switch (urlScheme!) {
            case "http", "https", "mailto", "tel":
                log.info("Delegating url load: \(request)")
                UIApplication.shared.openURL(request.mainDocumentURL!)
            case "lexicon":
                let entryId = UrlSchemes.parseLexiconEntryIdFromUrl(request.mainDocumentURL!.absoluteString)
                if (entryId != nil) {
                    log.info("Request to open lexicon article with id: \(String(describing: entryId))")
                    let dao = MainDao()
                    let entry = dao.getLexiconEntry(entryId!)
                    if (entry != nil) {
                        self.switchToLexiconArticle(for: entry!)
                    } else {
                        log.error("Cannot fetch lexicon article for display, id: \(String(describing: entryId))")
                    }
                } else {
                    log.error("Cannot parse lexicon entry id from request: \(request)")
                }
            default:
                log.warning("Unknown url scheme for request: \(request)")
            }
            return false
        } else if navigationType == .other {
            // this is needed to allow the web view to load with a String (loads "about:blank")
            if urlScheme! == "about" {
                return true
            }
            log.debug("Not reacting to unknown navigation event: \(request)")
            return false
        }
        // Prevent the user from navigating away in case of other navigation events
        return false
    }

    // -- MARK: Lexicon Articles

    // Closing a lexicon article leeds back to the last lexicon article before that
    // or to  view controller from which the first lexicon article was started
    func onCloseLexiconArticle() {
        let _ = self.lexiconDisplayControllerStack.popLast()
        let next = self.lexiconDisplayControllerStack.popLast()
        if(next != nil) {
            self.requestCenter(for: next!)
        } else {
            log.error("Empty stack on lexicon article close. Switching back to map")
            self.switchToPlainMap()
        }
    }


    // -- MARK: Private methods

    // setup the main view container with a left drawer for navigation
    private func setupCenterContainer() -> MMDrawerController {
        let navDrawerC = mainStoryboard.instantiateViewController(withIdentifier: "NavDrawerController") as! NavDrawerController
        let leftSideNav = UINavigationController(rootViewController: navDrawerC)

        let container = MMDrawerController()
        container.leftDrawerViewController = leftSideNav
        container.openDrawerGestureModeMask = .bezelPanningCenterView
        container.closeDrawerGestureModeMask = .panningDrawerView
        container.centerHiddenInteractionMode = .navigationBarOnly
        container.shouldStretchDrawer = false
        container.showsShadow = true
        return container
    }

    // fetch the controller identified by the storyboard id from our little cache or
    // instantiate a new one and save it in the caches
    private func getCenterController(_ identifier: String) -> UIViewController {
        let result: UIViewController
        if (self.centerViewControllers[identifier] != nil) {
            result = self.centerViewControllers[identifier]!
        } else {
            result = instantiateCenterController(identifier)
        }
        return result
    }

    private func instantiateCenterController(_ identifier: String) -> UIViewController {
        let result = self.mainStoryboard.instantiateViewController(withIdentifier: identifier)
        self.centerViewControllers[identifier] = result
        return result
    }

    // let the map view controller display a controller in a popup
    private func switchToMapPopup(with viewController: UIViewController) {
        let mapViewC = self.getCenterController("MapViewController") as! MapViewController
        self.requestCenter(for: mapViewC)
        mapViewC.displayAsPopup(controller: viewController)
        self.closeNavDrawer()
    }

}

