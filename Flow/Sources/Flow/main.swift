import Foundation
import AppKit


Config.workspacePath = "/Users/lzh/Workspace"
Config.specsRepoUrl = "http://localhost:3000/gitea/babybus-specs"

let podRepo = PodRepo("http://localhost:3000/gitea/NRDigitalVerifyView_Swift")

let newVersion = "23.23.23"

let flow = PodTagPushFlow(podRepo: podRepo)
try flow.run(tag: newVersion)

