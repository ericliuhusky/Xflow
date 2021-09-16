//
//  XflowApp.swift
//  Xflow
//
//  Created by lzh on 2021/9/15.
//

import SwiftUI

//@main
//struct XflowApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

@main
struct XflowApp {
    static func main() throws {
        Config.workspacePath = "/Users/lzh/Workspace"

        let repo = SpecsRepo("http://git.babybus.co/Babybus-iOS/Specs/babybus-specs")
        let podRepo = PodRepo("http://localhost:3000/gitea/NRDigitalVerifyView_Swift")

        let newVersion = "21.9.16"

        let flow = PodTagPushFlow(podRepo: podRepo)
        try flow.modifySpec(version: newVersion)
        
        
        // TODO: bookmark url
        let data = UserDefaults.standard.data(forKey: "bookmark")
        var isStale: Bool = false
        if let data = data {
            print(try? String(contentsOf: URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)))
        }
        
//        try flow.gitPush(tag: newVersion)

        //if !FileManager.default.fileExists(atPath: repo.path!) {
        //    run("git clone \(repo.url)")
        //}

        //FileManager.default.changeCurrentDirectoryPath("/Users/lzh/workspace")
        //try FileManager.default.createDirectory(at: URL(fileURLWithPath: "temp"), withIntermediateDirectories: false)

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            print(panel.url)
            
            let data = try panel.url?.bookmarkData()
            UserDefaults.standard.set(data, forKey: "bookmark")
            
        }
    }
}
