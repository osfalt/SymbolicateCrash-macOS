//
//  SymbolicateCrashService.swift
//  SymbolicateCrash
//
//  Created by Dre on 15/07/2018.
//  Copyright © 2018 Andrey Sidorovnin. All rights reserved.
//

import Foundation

final class SymbolicateCrashService {

    // MARK: - Internal types

    typealias SymbolicateCrashCompletion = (_ error: String?) -> Void

    // MARK: - Private types

    private enum Command {

        static var printXcodeDeveloperDirPath: String {
            return "xcode-select -p"
        }

        static var exportDeveloperDir: String {
            return "export DEVELOPER_DIR=$(\(printXcodeDeveloperDirPath))"
        }

        static func cdToSymbolicateCrash(xcodePath: String) -> String {
            return "cd \(xcodePath)/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/"
        }

        static func symbolicateCrash(inputCrash: String, symbols: String, output: String) -> String {
            return "./symbolicatecrash \(inputCrash) \(symbols) > \(output)"
        }

    }

    // MARK: - Private properties

    private let shell = ShellCommandExecutor()

    // MARK: - Internal methods

    func symbolicateCrash(_ crashInfo: SymbolicateCrashInfo,
                          qos: DispatchQoS.QoSClass,
                          completion: @escaping SymbolicateCrashCompletion) {

        DispatchQueue.global(qos: qos).async {
            guard let xcodeDeveloperDirPath = self.shell.runCommand(Command.printXcodeDeveloperDirPath).output,
                let xcodeLastIndex = xcodeDeveloperDirPath.range(of: ".app")?.upperBound else {
                    assertionFailure("Can't execute command: \(Command.printXcodeDeveloperDirPath)")
                    return
            }

            let xcodePath = String(xcodeDeveloperDirPath[..<xcodeLastIndex])

            let cdToSymbolicateCrashPath = Command.cdToSymbolicateCrash(xcodePath: xcodePath)
            let exportDeveloperDir = Command.exportDeveloperDir
            let symbolicateCrash = Command.symbolicateCrash(inputCrash: crashInfo.inputCrash,
                                                            symbols: crashInfo.symbols,
                                                            output: crashInfo.outputCrash)

            let result = self.shell.runCommand(cdToSymbolicateCrashPath, exportDeveloperDir, symbolicateCrash)

            DispatchQueue.main.async {
                if let error = result.error {
                    completion(error)
                    return
                }

                guard let _ = result.output else {
                    assertionFailure("Can't execute commands:\n\(cdToSymbolicateCrashPath)\n\(exportDeveloperDir)\n\(symbolicateCrash)")
                    completion("Unknown error")
                    return
                }

                completion(nil)
            }
        }
    }

}
