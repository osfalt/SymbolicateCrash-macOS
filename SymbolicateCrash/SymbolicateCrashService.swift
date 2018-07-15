//
//  SymbolicateCrashService.swift
//  SymbolicateCrash
//
//  Created by Dre on 15/07/2018.
//  Copyright © 2018 Andrey Sidorovnin. All rights reserved.
//

import Foundation

final class SymbolicateCrashService {

    // MARK: - Private types

    private enum Command {

        static var printXcodeDeveloperDirPath: String {
            return "xcode-select -p"
        }

        static var exportDeveloperDir: String {
            return "export DEVELOPER_DIR=$(\(printXcodeDeveloperDirPath))"
        }

        static func cdToSymbolicateCrashToolPath(xcodePath: String) -> String {
            return "cd \(xcodePath)/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/"
        }

        static func symbolicateCrash(inputCrash: String, symbols: String, output: String) -> String {
            return "./symbolicatecrash \(inputCrash) \(symbols) > \(output)"
        }

    }

    // MARK: - Internal methods

    func symbolicateCrash(_ inputCrash: String, symbols: String, output: String) {
//        guard let xcodeDeveloperDirPath = runShellCommand(command: Command.printXcodeDeveloperDirPath) else {
//            assertionFailure("Can't execute '\(Command.printXcodeDeveloperDirPath)' command")
//            return
//        }
//
//        print("xcodeDeveloperDirPath: \(xcodeDeveloperDirPath)")

        let commands = Command.cdToSymbolicateCrashToolPath(xcodePath: "/Applications/Xcode.app") + ";" +
            Command.exportDeveloperDir + ";" +
            Command.symbolicateCrash(inputCrash: inputCrash, symbols: symbols, output: output)

        print("commands: \(commands)")

        guard let _ = runShellCommand(commands) else {
            assertionFailure("Can't execute '\(commands)' commands")
            return
        }
    }

    // MARK: - Private methods

    private func runShellCommand(_ command: String) -> String? {
        let pipe = Pipe()

        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", command]
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        return String(data: data, encoding: String.Encoding.utf8)
    }

}
