//
//  AppDelegate.swift
//  HistoriaApp
//
//  Created by David on 10.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

import SpeedLog
import MMDrawerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties for Navigation

    private var centerContainer: MMDrawerController?

    private let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

    private var centerViewControllers = Dictionary<String, UIViewController>()

    private var currentCenterController: UIViewController?

    // MARK: Normal AppDelegate stuff

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Set logging options for the app
        SpeedLog.mode = [ .FullCodeLocation ]

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
            SpeedLog.print("INFO", "Controller \(type(of: controller)) already in center.")
            return
        }
        // setup the new center controller and correctly linkt it to the navigation drawer
        let centerNavC = UINavigationController(rootViewController: controller)
        self.centerContainer?.centerViewController = centerNavC
        self.centerContainer?.closeDrawer(animated: true, completion: nil)
        self.currentCenterController = controller
    }

    // switch the center view controller to the one identified by the storyboard id
    // re-using an old one or instantiating a new one as needed
    func switchToCenterController(_ identifier: String) {
        // retrieve the new center
        let viewController = self.getCenterController(identifier)
        self.requestCenter(for: viewController)
    }

    func switchToTourSelection() {
        // the tour selection is displayed as a popup on the map and interacts with it on
        // tour selection
        let tourSelectionC = self.getCenterController("TourSelectionViewController") as! TourSelectionViewController
        let mapViewC = self.getCenterController("MapViewController") as! MapViewController
        tourSelectionC.tourSelectionDelegate = mapViewC
        self.requestCenter(for: mapViewC)
        mapViewC.displayPopup(controller: tourSelectionC)
        self.toggleNavDrawer()
    }

    // open or close the left navigation drawer
    func toggleNavDrawer() {
        centerContainer?.toggle(.left, animated: true, completion: nil)
    }

    func closeNavDrawer() {
        self.centerContainer?.closeDrawer(animated: true, completion: nil)
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
            result = self.mainStoryboard.instantiateViewController(withIdentifier: identifier)
            self.centerViewControllers[identifier] = result
        }
        return result
    }

}

