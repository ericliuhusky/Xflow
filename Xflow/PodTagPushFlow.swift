//
//  PodTagPushFlow.swift
//  Xflow
//
//  Created by lzh on 2021/9/16.
//

import Foundation
import Regex

struct PodTagPushFlow {
    let podRepo: PodRepo
    
    func modifySpec(version newVersion: String) throws {
        guard let specPath = podRepo.specPath else { return }
        guard let specContent = try? String(contentsOfFile: specPath) else { return }
        guard let versionLine = specContent.regex.firstMatch(pattern: #"s.version\s*=\s*'[0-9\.]+'"#) else { return }
        guard let version = versionLine.regex.firstMatch(pattern: #"'[0-9\.]+'"#)?.replacingOccurrences(of: "'", with: "") else { return }
        
        guard let versionRange = versionLine.range(of: version) else { return }
        let newVersionLine = versionLine.replacingCharacters(in: versionRange, with: newVersion)
        guard let versionLineRange = specContent.range(of: versionLine) else { return }
        let newSpecContent = specContent.replacingCharacters(in: versionLineRange, with: newVersionLine)
        
        try newSpecContent.write(toFile: specPath, atomically: true, encoding: .utf8)
    }
    
    func gitPush(tag: String) throws {
        guard
            let path = podRepo.path,
            let specName = podRepo.specName
        else { return }
        FileManager.default.changeCurrentDirectoryPath(path)
        
        try Shell.run("git add \(specName)")
        try Shell.run("git commit -m '[Update] \(tag)'")
        try Shell.run("git push")
    }
    
    func podRepoPush() {
        
    }
}
