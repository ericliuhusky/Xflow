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
        
        if FileManager.default.changeCurrentDirectoryPath(path) {
            try ShellCommand.gitPush(filePath: specName, message: "[Update]\(tag)")
            try ShellCommand.git(tag: tag)
        }
    }
    
    func podRepoPush(version: String) throws {
        guard
            let specsRepo = SpecsRepo.repo,
            let specsRepoPath = specsRepo.path,
            let specsRepoSpecsPath = specsRepo.specsPath,
            let workspacePath = Config.workspacePath,
            let podRepoSpecPath = podRepo.specPath,
            let podRepoName = podRepo.name,
            let podRepoSpecName = podRepo.specName
        else { return }
        
        let specsRepoPodVersionPath = specsRepoSpecsPath + "/\(podRepoName)/\(version)"
        let specsRepoPodSpecPath = specsRepoPodVersionPath + "/\(podRepoSpecName)"
        
        if !FileManager.default.fileExists(atPath: specsRepoPath) {
            if FileManager.default.changeCurrentDirectoryPath(workspacePath) {
                try Shell.run("git clone \(specsRepo.url)")
            }
        }

        try FileManager.default.createDirectory(atPath: specsRepoPodVersionPath, withIntermediateDirectories: true)
        try FileManager.default.copyItem(atPath: podRepoSpecPath, toPath: specsRepoPodSpecPath)

        if FileManager.default.changeCurrentDirectoryPath(specsRepoPath) {
            try ShellCommand.gitPush(filePath: specsRepoPodSpecPath, message: "[Update] \(podRepoName) (\(version))")
        }
    }
    
    func run(tag: String) throws {
        try modifySpec(version: tag)
        try gitPush(tag: tag)
        try podRepoPush(version: tag)
    }
}
