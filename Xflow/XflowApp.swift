//
//  XflowApp.swift
//  Xflow
//
//  Created by lzh on 2021/9/15.
//

import SwiftUI

@main
struct XflowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//// TODO: bookmark url
//let data = UserDefaults.standard.data(forKey: "bookmark")
//var isStale: Bool = false
//if let data = data {
//    print(try? String(contentsOf: URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)))
//}
//
//let panel = NSOpenPanel()
//panel.canChooseDirectories = true
//if panel.runModal() == .OK {
//    print(panel.url)
//    
//    let data = try panel.url?.bookmarkData()
//    UserDefaults.standard.set(data, forKey: "bookmark")
//    
//}
