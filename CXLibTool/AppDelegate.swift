//
//  AppDelegate.swift
//  CXLibTool
//
//  Created by abelchen on 2018/8/8.
//  Copyright © 2018年 com.tencent.abelchen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if(flag){
            return false
        }else{
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
            return true
        }
    }
}

