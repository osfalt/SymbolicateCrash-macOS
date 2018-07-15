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

    // MARK: - Private properties

    private let shell = ShellCommandExecutor()

    // MARK: - Internal methods

    func symbolicateCrash(_ inputCrash: String, symbols: String, output: String) {
        guard let xcodeDeveloperDirPath = shell.runCommand(Command.printXcodeDeveloperDirPath),
            let xcodeLastIndex = xcodeDeveloperDirPath.range(of: ".app")?.upperBound else {
            assertionFailure("Can't execute command: \(Command.printXcodeDeveloperDirPath)")
            return
        }

        let xcodePath = String(xcodeDeveloperDirPath[..<xcodeLastIndex])

        let commands = Command.cdToSymbolicateCrashToolPath(xcodePath: xcodePath) + ";" +
            Command.exportDeveloperDir + ";" +
            Command.symbolicateCrash(inputCrash: inputCrash, symbols: symbols, output: output)

        print("commands: \(commands)")

        guard let _ = shell.runCommand(commands) else {
            assertionFailure("Can't execute commands: \(commands)")
            return
        }
    }

}
