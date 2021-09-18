import Foundation
import AppKit


Config.workspacePath = "/Users/lzh/Workspace"
//Config.specsRepoUrl = "http://localhost:3000/gitea/babybus-specs"
//
//let podRepo = PodRepo("http://localhost:3000/gitea/NRDigitalVerifyView_Swift")
//
//let newVersion = "23.23.23"
//
//let flow = PodTagPushFlow(podRepo: podRepo)
//try flow.run(tag: newVersion)


struct ProjectRepo {
    let url: String
    
    init(_ url: String) {
        self.url = url
    }
    
    private var components: [String] {
        if url.hasSuffix(".git") {
            return url.dropLast(4).split(separator: "/").map { String($0) }
        }
        return url.split(separator: "/").map { String($0) }
    }
    
    var name: String? {
        components.last
    }
    
    var path: String? {
        guard
            let name = name,
            let workspacePath = Config.workspacePath
        else { return nil }
        return workspacePath + "/\(name)"
    }
    
    var podfilePath: String? {
        guard let path = path else { return nil }
        return path + "/Podfile"
    }
}

let repo = ProjectRepo("http://git.babybus.co/Platform-iOS/Business-Two/BabyRecommend/Baby_Recommend")
let podfileContent = try! String(contentsOfFile: repo.podfilePath!)


let podLines = podfileContent.regex.matches(pattern: #"\{\s*:names\s*=>\s*\['[a-zA-Z0-9_/]+'\],.*\}"#)
print(podLines.count)

