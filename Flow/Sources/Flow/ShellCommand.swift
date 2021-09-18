//
//  ShellCommand.swift
//  
//
//  Created by lzh on 2021/9/18.
//

struct ShellCommand {
    static func gitPush(filePath: String, message: String) throws {
        try Shell.run("git pull")
        try Shell.run("git add \(filePath)")
        try Shell.run("git commit -m '\(message)'")
        try Shell.run("git push")
    }
    
    static func git(tag: String) throws {
        try Shell.run("git tag \(tag)")
        try Shell.run("git push origin \(tag)")
    }
}
