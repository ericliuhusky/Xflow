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

Config.podRepoUrls = [
    "http://git.babybus.co/Platform-iOS/Business/BBDigitalVerifyView",
    "http://git.babybus.co/Platform-iOS/Business-Two/BabyRecommend/BRPayKit"
]




struct Project {
    let repo: ProjectRepo
    
    var pods: [Pod] {
        guard let podfilePath = repo.podfilePath else { return [] }
        guard let podfileContent = try? String(contentsOfFile: podfilePath) else { return [] }
        let podLines = podfileContent.regex.matches(pattern: #"\{\s*:names\s*=>\s*\['[a-zA-Z0-9_/]+'\],.*\}"#)
        var pods = podLines.compactMap { podLine -> Pod? in
            guard let nameField = podLine.regex.firstMatch(pattern: #"\['[a-zA-Z0-9_/]+'\]"#) else { return nil }
            let name = nameField.regex.replacingMatches(pattern: #"[\[\]']*"#, with: "")
            guard let podRepo = Config.podRepoUrls.map({ url in
                PodRepo(url)
            }).first(where: { repo in
                repo.name == name
            }) else { return nil }
            
            if podLine.regex.firstMatch(pattern: #":method\s*=>\s*REMOTE_VERSION"#) != nil {
                if let versionField = podLine.regex.firstMatch(pattern: #":version\s*=>\s*'[~>=<\.\s0-9]+'"#) {
                    guard let version = versionField.regex.firstMatch(pattern: #"'[~>=<\.\s0-9]+'"#)?.replacingOccurrences(of: "'", with: "") else { return nil }
                    
                    return Pod(repo: podRepo, source: .version(version))
                } else {
                    return Pod(repo: podRepo, source: .version("up to date"))
                }
            } else if let branchField = podLine.regex.firstMatch(pattern: #":branch\s*=>\s*'[a-zA-Z0-9_/]+'"#) {
                guard let branch = branchField.regex.firstMatch(pattern: #"'[a-zA-Z0-9_/]+'"#)?.replacingOccurrences(of: ".", with: "") else { return nil }
                return Pod(repo: podRepo, source: .branch(branch))
            } else if podLine.regex.firstMatch(pattern: #":method\s*=>\s*LOCAL"#) != nil {
                return Pod(repo: podRepo, source: .local)
            }
            
            return Pod(repo: podRepo, source: nil)
        }
        
        pods = pods.filter { pod in
            pods.filter { $0.repo.name == pod.repo.name }.count <= 1 || pod.source == .local
        }
        
        return pods
    }
}

struct Pod {
    enum Source: Equatable {
        case version(String?)
        case branch(String)
        case local
    }
    
    let repo: PodRepo
    
    let source: Source?
    
    func setSource(_ source: Source) throws {
        guard let podfilePath = Flow.repo.podfilePath else { return }
        guard let podfileContent = try? String(contentsOfFile: podfilePath) else { return }
        guard let podLine = podfileContent.regex.firstMatch(pattern: "\\{\\s*:names\\s*=>\\s*\\['\(repo.name!)'\\],.*\\}") else { return }
        guard let podLineRange = podfileContent.range(of: podLine) else { return }
        switch source {
        case .version(let string):
            if let string = string {
                let newPodLine = "{ :names => ['\(repo.name!)'], :version => '\(string)', :method => 'REMOTE_VERSION' }"
                
                let newPodfileContent = podfileContent.replacingCharacters(in: podLineRange, with: newPodLine)
                try newPodfileContent.write(toFile: podfilePath, atomically: true, encoding: .utf8)
            } else {
                let newPodLine = "{ :names => ['\(repo.name!)'], :method => 'REMOTE_VERSION' }"
                
                let newPodfileContent = podfileContent.replacingCharacters(in: podLineRange, with: newPodLine)
                try newPodfileContent.write(toFile: podfilePath, atomically: true, encoding: .utf8)
            }
            
        case .branch(let string):
            let newPodLine = "{ :names => ['\(repo.name!)'], :git => '\(repo.url)', :branch => '\(string)' }"
            
            let newPodfileContent = podfileContent.replacingCharacters(in: podLineRange, with: newPodLine)
            try newPodfileContent.write(toFile: podfilePath, atomically: true, encoding: .utf8)
        case .local:
            let newPodLine = "{ :names => ['\(repo.name!)'], :method => 'LOCAL' }"
            
            let newPodfileContent = podfileContent.replacingCharacters(in: podLineRange, with: newPodLine)
            try newPodfileContent.write(toFile: podfilePath, atomically: true, encoding: .utf8)
        }
    }
}

let project = Project(repo: repo)
print(project.pods)
