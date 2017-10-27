//
//  AppDelegate.swift
//  mymaps
//
//  Created by Peter on 2017. 10. 26..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let newGPXFile = Notification.Name("newGPXFile")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let documentURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last else{return false}
        var fileName = "test.xml"
        if let existFileName = url.pathComponents.last {
            fileName = existFileName
        }
        let path = documentURL.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: url, to: path)
            NotificationCenter.default.post(name: .newGPXFile, object: path)
            return true
        }catch{
            return false
        }
    }


}

