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
                    return Pod(repo: podRepo, source: .version(nil))
                }
            } else if let branchField = podLine.regex.firstMatch(pattern: #":branch\s*=>\s*'[a-zA-Z0-9_/]+'"#) {
                guard let branch = branchField.regex.firstMatch(pattern: #"'[a-zA-Z0-9_/]+'"#)?.replacingOccurrences(of: ".", with: "") else { return nil }
                return Pod(repo: podRepo, source: .branch(branch))
            } else if podLine.regex.firstMatch(pattern: #":method\s*=>\s*LOCAL"#) != nil {
                return Pod(repo: podRepo, source: .local)
            }
            
            return Pod(repo: podRepo, source: nil)
        }
        
        pods = pods.map { pod in
            if localPods.contains(where: { localPod in
                localPod.repo.name == pod.repo.name
            }) {
                return Pod(repo: pod.repo, source: .local)
            }
            return pod
        }
        
        return pods
    }
    
    var localPods: [Pod] {
        guard let xflowContent = try? String(contentsOfFile: repo.path! + "/xflow.rb") else { return [] }
        let podLines = xflowContent.regex.matches(pattern: #"\{\s*:names\s*=>\s*\['[a-zA-Z0-9_/]+'\],.*\}"#)
        return podLines.compactMap { podLine in
            guard let nameField = podLine.regex.firstMatch(pattern: #"\['[a-zA-Z0-9_/]+'\]"#) else { return nil }
            let name = nameField.regex.replacingMatches(pattern: #"[\[\]']*"#, with: "")
            guard let podRepo = Config.podRepoUrls.map({ url in
                PodRepo(url)
            }).first(where: { repo in
                repo.name == name
            }) else { return nil }
            return Pod(repo: podRepo, source: .local)
        }
    }
    
    func setPod(_ pod: Pod) throws {
        guard let podfilePath = repo.podfilePath else { return }
        guard let podfileContent = try? String(contentsOfFile: podfilePath) else { return }
        guard let podLine = podfileContent.regex.firstMatch(pattern: "\\{\\s*:names\\s*=>\\s*\\['\(pod.repo.name!)'\\],.*\\}") else { return }
        guard let podLineRange = podfileContent.range(of: podLine) else { return }
        switch pod.source {
        case .version(let string):
            if let string = string {
                let newPodLine = "{ :names => ['\(pod.repo.name!)'], :version => '\(string)', :method => 'REMOTE_VERSION' }"
                
                let newPodfileContent = podfileContent.replacingCharacters(in: podLineRange, with: newPodLine)
                try newPodfileContent.write(toFile: podfilePath, atomically: true, encoding: .utf8)
            } else {
                let newPodLine = "{ :names => ['\(pod.repo.name!)'], :method => 'REMOTE_VERSION' }"
                
                let newPodfileContent = podfileContent.replacingCharacters(in: podLineRange, with: newPodLine)
                try newPodfileContent.write(toFile: podfilePath, atomically: true, encoding: .utf8)
            }
            
        case .branch(let string):
            let newPodLine = "{ :names => ['\(pod.repo.name!)'], :git => '\(pod.repo.url)', :branch => '\(string)' }"
            
            let newPodfileContent = podfileContent.replacingCharacters(in: podLineRange, with: newPodLine)
            try newPodfileContent.write(toFile: podfilePath, atomically: true, encoding: .utf8)
        case .local:
            if !FileManager.default.fileExists(atPath: repo.path! + "/xflow.rb") {
                FileManager.default.createFile(atPath: repo.path! + "/xflow.rb", contents: nil)
            }

            try xflowModules(localPods: localPods + [pod]).write(toFile: repo.path! + "/xflow.rb", atomically: true, encoding: .utf8)
        case .none:
            break
        }
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
}

let project = Project(repo: repo)
print(project.pods)
try project.setPod(Pod(repo: PodRepo("http://git.babybus.co/Platform-iOS/Business/BBDigitalVerifyView"), source: .version(nil)))

func xflowModules(localPods: [Pod]) -> String {
    let localPodsString = localPods.reduce("") { result, pod in
        result + "  { :names => ['\(pod.repo.name!)'], :method => LOCAL },\n"
    }
    
    return """
    #!/usr/bin/ruby
    require File.join(File.dirname(__FILE__), '../PodBox.rb')


    def xflow_config
        { :name => :xflow,
          :pathes => ['/Users/lzh/Workspace/Pods/Recommend',
                      '/Users/lzh/Workspace/Pods/Business',
                      '/Users/lzh/Desktop'],
          :force_local => false }
    end

    def xflow_modules
    [
    \(localPodsString)
    ]
    end
    """
}
