//
//  ShellCommandExecutor.swift
//  SymbolicateCrash
//
//  Created by Dre on 16/07/2018.
//  Copyright © 2018 Andrey Sidorovnin. All rights reserved.
//

import Foundation

final class ShellCommandExecutor {

    func runCommand(_ command: String) -> String? {
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
