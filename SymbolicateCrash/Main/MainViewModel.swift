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
    let symbolicateButtonIsEnabled = DynamicProperty<Bool>(false)

    // MARK: - Private properties
    private let router: MainRouterProtocol
    private let symbolicateCrashService: SymbolicateCrashServiceProtocol

    private var outputCrashPathWasChanged = false
    private var inputCrashLogPathToken: String?
    private var symbolsPathToken: String?
    private var outputCrashLogPathToken: String?
    private var progressIsStartedToken: String?

    // MARK: - Init
    init(router: MainRouterProtocol, symbolicateCrashService: SymbolicateCrashServiceProtocol) {
        self.router = router
        self.symbolicateCrashService = symbolicateCrashService
        observeForSymbolicateButtonEnabledValue()
    }

    deinit {
        inputCrashLogPath.unbind(inputCrashLogPathToken)
        symbolsPath.unbind(symbolsPathToken)
        outputCrashLogPath.unbind(outputCrashLogPathToken)
        progressIsStarted.unbind(progressIsStartedToken)
    }

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
            guard let self = self else { return }
            self.symbolsPath.value = fileURL.path
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
        progressIsStarted.value = true
        errorMessage.value = nil

        let outputCrashLogPath = makeOutputCrashLogPath(from: inputCrashLogPath.value)
        let symbolicateCrashInfo = SymbolicateCrashInfo(inputCrash: inputCrashLogPath.value,
                                                        symbols: symbolsPath.value,
                                                        outputCrash: outputCrashLogPath)

        symbolicateCrashService.symbolicateCrash(symbolicateCrashInfo, qos: .userInitiated) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage.value = "Error: \(error)"
            } else {
                self.errorMessage.value = nil
                self.router.openFinderAndSelectFile(at: outputCrashLogPath)
            }

            self.progressIsStarted.value = false
        }
    }

    // MARK: - Private methods
    private func makeOutputCrashLogPath(from inputCrashLogPath: String) -> String {
        let inputCrashLogURL = URL(fileURLWithPath: inputCrashLogPath)
        let fileExtension = "." + inputCrashLogURL.pathExtension

        var outputCrashLogName = inputCrashLogURL.lastPathComponent
        if let fileExtensionRange = outputCrashLogName.range(of: fileExtension) {
            outputCrashLogName.removeSubrange(fileExtensionRange)
        }

        return outputCrashLogPath.value + "/\(outputCrashLogName + "-symbolicated").crash"
    }

    private func observeForSymbolicateButtonEnabledValue() {
        inputCrashLogPathToken = inputCrashLogPath.bind { [weak self] _ in
            self?.updateSymbolicateButtonEnabledValue()
        }

        symbolsPathToken = symbolsPath.bind { [weak self] _ in
            self?.updateSymbolicateButtonEnabledValue()
        }

        outputCrashLogPathToken = outputCrashLogPath.bind { [weak self] _ in
            self?.updateSymbolicateButtonEnabledValue()
        }

        progressIsStartedToken = progressIsStarted.bind { [weak self] _ in
            self?.updateSymbolicateButtonEnabledValue()
        }
    }

    private func updateSymbolicateButtonEnabledValue() {
        symbolicateButtonIsEnabled.value = !progressIsStarted.value
            && !inputCrashLogPath.value.isEmpty
            && !symbolsPath.value.isEmpty
            && !outputCrashLogPath.value.isEmpty
    }

}
