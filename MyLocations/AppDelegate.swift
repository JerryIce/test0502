//
//  AppDelegate.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/7.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import UIKit
import CoreData



//MARK:- coredataError提示函数,全局函数，用于处理 fatal Core errors.
let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"
func fatalCoreDataError(error:Error){
    print("******Fatal error:\(error)")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil)
}

@UIApplicationMain
//MARK:- AppDelegate类
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //MARK:didFinish方法中添加东西
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        customizeAppearance()
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
        }
        listenForFatalCoreDataNotification()
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
    //MARK:- 懒加载coredata内容
    lazy var managedObjectContext: NSManagedObjectContext = {
        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd")
            else{
            fatalError("Could not find data model in app bundle")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL)
            else { fatalError("Error initializing model from: \(modelURL)")
        }
        let urls = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0]
        let storeURL = documentsDirectory.appendingPathComponent("DataStore.sqlite")
        do {
            let coordinator = NSPersistentStoreCoordinator(
                managedObjectModel: model)
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,configurationName: nil, at: storeURL, options: nil)
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context } catch {
                fatalError("Error adding persistent store at \(storeURL):\(error)") }
    }()
    //MARK:监听fatalcoreError
    func listenForFatalCoreDataNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil, queue: OperationQueue.main, using: { notification in
            let alert = UIAlertController(title: "Internal Error", message: "有fatal Error，无法继续。\n\n"+"Press OK to 终止。", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
        })
    }
    //MARK:添加alert警告窗口
    func viewControllerForShowingAlert()-> UIViewController{
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController{
            return presentedViewController
        }else {
            return rootViewController
        }
    }
    //MARK:- 外观
    func customizeAppearance(){
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UITabBar.appearance().barTintColor = UIColor.black
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }
}

