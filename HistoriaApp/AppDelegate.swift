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

    // MARK: Normal AppDelegate stuff

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Set logging options for the app
        SpeedLog.mode = [ .FullCodeLocation ]

        // Set thea appearence of page view indicators
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        pageControl.backgroundColor = UIColor.white

        // setup the Main container with navigation with a navigation and the map
        // as first view
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

    // switch the center view controller to the one identified by the storyboard id
    // re-using an old one or instantiating a new one as needed
    func switchToCenterController(_ identifier: String) {
        var viewController: UIViewController?

        if (self.centerViewControllers[identifier] != nil) {
            viewController = self.centerViewControllers[identifier]
        } else {
            viewController = self.mainStoryboard.instantiateViewController(withIdentifier: identifier)
        }

        guard viewController != nil else {
            SpeedLog.print("ERROR", "Cannot instantiate center view controller: \(identifier)")
            return
        }

        let centerNavC = UINavigationController(rootViewController: viewController!)
        self.centerContainer?.centerViewController = centerNavC
        self.centerContainer?.closeDrawer(animated: true, completion: nil)
        self.centerViewControllers[identifier] = viewController
    }

    // open or close the left navigation drawer
    func toggleNavDrawer() {
        centerContainer?.toggle(.left, animated: true, completion: nil)
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

}

