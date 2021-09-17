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
    
    private var components: [String] {
        url.split(separator: "/").map { String($0) }
    }
    
    var name: String? {
        components.last
    }
    
    var path: String? {
        guard let name = name else { return nil }
        return FileManager.default.currentDirectoryPath + "/\(name)"
    }
}
