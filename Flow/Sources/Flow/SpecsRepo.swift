//
//  SpecsRepo.swift
//  Xflow
//
//  Created by lzh on 2021/9/16.
//

import Foundation

struct SpecsRepo {
    var url: String
    
    init(_ url: String) {
        self.url = url
    }
    
    static let repo: SpecsRepo? = {
        guard let url = Config.specsRepoUrl else { return nil }
        return SpecsRepo(url)
    }()
    
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
    
    var specsPath: String? {
        guard let path = path else { return nil }
        return path + "/Specs"
    }
}
