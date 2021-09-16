//
//  PodRepo.swift
//  Xflow
//
//  Created by lzh on 2021/9/16.
//

struct PodRepo {
    var url: String

    init(_ url: String) {
        self.url = url
    }

    private var components: [String] {
        url.split(separator: "/").map { String($0) }
    }

    var name: String? {
        components.last
    }

    var projectName: String? {
        components.dropLast().last
    }

    var path: String? {
        guard
            let name = name,
            let projectName = projectName,
            let workspacePath = Config.workspacePath
        else { return nil }
        return workspacePath + "/Pods/\(projectName)" + "/\(name)"
    }
    
    var specName: String? {
        guard let name = name else { return nil }
        return "\(name).podspec"
    }
    
    var specPath: String? {
        guard
            let path = path,
            let specName = specName
        else { return nil }
        return path + "/\(specName)"
    }
}
