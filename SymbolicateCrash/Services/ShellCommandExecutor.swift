//
//  ShellCommandExecutor.swift
//  SymbolicateCrash
//
//  Created by Dre on 16/07/2018.
//  Copyright © 2018 Andrey Sidorovnin. All rights reserved.
//

import Foundation

final class ShellCommandExecutor {

    func runCommand(_ commands: String...) -> (output: String?, error: String?) {
        print("commands: \(commands)")

        let stdout = Pipe()
        let stderr = Pipe()

        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", commands.joined(separator: ";")]
        process.standardOutput = stdout
        process.standardError = stderr
        process.launch()

        let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errorData = stderr.fileHandleForReading.readDataToEndOfFile()

        let result = String(data: outputData, encoding: String.Encoding.utf8)?.trimmingCharacters(in: .newlines)

        var error: String?
        if let err = String(data: errorData, encoding: String.Encoding.utf8)?.trimmingCharacters(in: .newlines) {
            error = err.isEmpty ? nil : err
        }

        return (result, error)
    }

}
