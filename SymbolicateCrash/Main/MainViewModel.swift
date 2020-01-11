//
//  MainViewModel.swift
//  SymbolicateCrash
//
//  Created by Dre on 11.01.2020.
//  Copyright © 2020 Andrey Sidorovnin. All rights reserved.
//

import Foundation

// MARK: - Protocol
protocol MainViewModelProtocol: AnyObject {

    var inputCrashLogPath: DynamicProperty<String> { get }
    var symbolsPath: DynamicProperty<String> { get }
    var outputCrashLogPath: DynamicProperty<String> { get }
    var errorMessage: DynamicProperty<String?> { get }
    var progressIsStarted: DynamicProperty<Bool> { get }
    var symbolicateButtonIsEnabled: DynamicProperty<Bool> { get }

    func selectInputCrashLogButtonDidTap()
    func selectSymbolsButtonDidTap()
    func selectOutputCrashLogButtonDidTap()
    func symbolicateButtonDidTap()

}

// MARK: - Implementation
class MainViewModel: MainViewModelProtocol {

    // MARK: - Internal properties
    let inputCrashLogPath = DynamicProperty<String>("")
    let symbolsPath = DynamicProperty<String>("")
    let outputCrashLogPath = DynamicProperty<String>("")
    let errorMessage = DynamicProperty<String?>(nil)
    let progressIsStarted = DynamicProperty<Bool>(false)
    let symbolicateButtonIsEnabled: DynamicProperty<Bool> = .init(false)

    var symbolicateCrashInfo: SymbolicateCrashInfo {
//        let outputCrashLogPath = makeOutputCrashLogPath(from: inputCrashLogPath)
        return SymbolicateCrashInfo(inputCrash: inputCrashLogPath.value,
                                    symbols: symbolsPath.value,
                                    outputCrash: "outputCrashLogPath")
    }

//    return !progressIsStarted.value
//        && !inputCrashLogPath.value.isEmpty
//        && !symbolsPath.value.isEmpty
//        && !outputCrashLogPath.value.isEmpty

    // MARK: - Private properties
    private let router: MainRouterProtocol = MainRouter()
    private let symbolicateCrashService = SymbolicateCrashService()

    private var outputCrashPathWasChanged = false

    // MARK: - Init
    init() {
    }

//    convenience init(router: MainRouterProtocol, symbolicateCrashService: SymbolicateCrashService) {
//        self.router = router
//        self.symbolicateCrashService = symbolicateCrashService
//    }

    // MARK: - Internal methods
    func selectInputCrashLogButtonDidTap() {
        router.openPanelForInputCrashLog { [weak self] fileURL in
            guard let self = self else { return }
            self.inputCrashLogPath.value = fileURL.path
            if !self.outputCrashPathWasChanged {
                self.outputCrashLogPath.value = fileURL.deletingLastPathComponent().path
            }
        }
    }

    func selectSymbolsButtonDidTap() {
        router.openPanelForSymbols { [weak self] fileURL in
            self?.symbolsPath.value = fileURL.path
        }
    }

    func selectOutputCrashLogButtonDidTap() {
        router.openPanelForOutputCrashLog { [weak self] fileURL in
            guard let self = self else { return }
            self.outputCrashPathWasChanged = true
            self.outputCrashLogPath.value = fileURL.path
        }
    }

    func symbolicateButtonDidTap() {

    }

}
