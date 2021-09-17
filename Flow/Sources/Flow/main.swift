import Foundation
import AppKit


Config.workspacePath = "/Users/lzh/Workspace"

let repo = SpecsRepo("http://git.babybus.co/Babybus-iOS/Specs/babybus-specs")
let podRepo = PodRepo("http://localhost:3000/gitea/NRDigitalVerifyView_Swift")

let newVersion = "21.9.18"

let flow = PodTagPushFlow(podRepo: podRepo)
try flow.modifySpec(version: newVersion)
try flow.gitPush(tag: newVersion)

//if !FileManager.default.fileExists(atPath: repo.path!) {
//    run("git clone \(repo.url)")
//}

//FileManager.default.changeCurrentDirectoryPath("/Users/lzh/workspace")
//try FileManager.default.createDirectory(at: URL(fileURLWithPath: "temp"), withIntermediateDirectories: false)
