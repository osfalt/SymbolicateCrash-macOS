//
//  MainViewModel.swift
//  SymbolicateCrash
//
//  Created by Dre on 11.01.2020.
//  Copyright © 2020 Andrey Sidorovnin. All rights reserved.
//

import Foundation

struct MainViewModel {

    var inputCrashLogPath = ""
    var symbolsPath = ""
    var outputCrashLogPath = ""
    var progressIsStarted = false
    var errorMessage = ""

    var symbolicateButtonIsEnabled: Bool {
        return !progressIsStarted && !inputCrashLogPath.isEmpty && !symbolsPath.isEmpty && !outputCrashLogPath.isEmpty
    }

}
