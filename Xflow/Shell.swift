//
//  Shell.swift
//  Xflow
//
//  Created by lzh on 2021/9/16.
//

import Foundation

struct Shell {
    static func run(_ arguments: String, completionHandler: @escaping (Bool, String?) -> Void) throws {
        let pipe = Pipe()

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", arguments]
        process.standardOutput = pipe

        try process.run()
        
        DispatchQueue.global().async {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            pipe.fileHandleForReading.closeFile()
            
            DispatchQueue.main.async {
                completionHandler(process.terminationStatus == 0, String(data: data, encoding: .utf8))
            }
        }
    }

    static func run(_ arguments: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", arguments]
        
        try process.run()
        process.waitUntilExit()
    }
}
