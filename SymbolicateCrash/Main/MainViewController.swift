//
//  MainViewController.swift
//  SymbolicateCrash
//
//  Created by Dre on 14/07/2018.
//  Copyright © 2018 Andrey Sidorovnin. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    // MARK: - Private properties
    @IBOutlet private weak var inputCrashButton: NSButton!
    @IBOutlet private weak var symbolsButton: NSButton!
    @IBOutlet private weak var outputCrashButton: NSButton!

    @IBOutlet private weak var inputCrashTextField: NSTextField!
    @IBOutlet private weak var symbolsTextField: NSTextField!
    @IBOutlet private weak var outputCrashTextField: NSTextField!

    @IBOutlet private weak var symbolicateButton: NSButton!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var errorLabel: NSTextField!

    private var viewModel: MainViewModelProtocol = MainViewModel()
    private let symbolicateCrashService = SymbolicateCrashService()

//    private var symbolicateCrashInfo: SymbolicateCrashInfo {
//        let inputCrashLogPath = viewModel.inputCrashLogPath
//        let symbolsPath = viewModel.symbolsPath
//        let outputCrashLogPath = makeOutputCrashLogPath(from: inputCrashLogPath)
//
//        return SymbolicateCrashInfo(inputCrash: inputCrashLogPath, symbols: symbolsPath, outputCrash: outputCrashLogPath)
//    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bindToViewModel()
    }

    // MARK: - Actions
    @IBAction
    private func selectInputCrash(_ sender: NSButton) {
        viewModel.selectInputCrashLogButtonDidTap()
    }

    @IBAction
    private func selectSymbols(_ sender: NSButton) {
        viewModel.selectSymbolsButtonDidTap()
    }

    @IBAction
    private func selectOutputCrash(_ sender: NSButton) {
        viewModel.selectOutputCrashLogButtonDidTap()
    }

    @IBAction
    private func symbolicateCrash(_ sender: NSButton) {
        viewModel.symbolicateButtonDidTap()
    }

    // MARK: - Private methods
    private func configure() {
        inputCrashTextField.delegate = self
        symbolsTextField.delegate = self
        outputCrashTextField.delegate = self

        symbolicateButton.keyEquivalent = "\r"
    }

    private func bindToViewModel() {
        viewModel.inputCrashLogPath.bind { [weak self] in self?.inputCrashTextField.stringValue = $0 }
        viewModel.symbolsPath.bind { [weak self] in self?.symbolsTextField.stringValue = $0 }
        viewModel.outputCrashLogPath.bind { [weak self] in self?.outputCrashTextField.stringValue = $0 }

        viewModel.errorMessage.bind { [weak self] errorMessage in
            guard let self = self else { return }
            self.errorLabel.isHidden = errorMessage == nil
            self.errorLabel.stringValue = errorMessage ?? ""
        }

        viewModel.progressIsStarted.bind { [weak self] in
            guard let self = self else { return }
            $0 ? self.progressIndicator.startAnimation(nil) : self.progressIndicator.stopAnimation(nil)

            let controlsAreEnabled = !$0
            self.inputCrashTextField.isEnabled = controlsAreEnabled
            self.inputCrashButton.isEnabled = controlsAreEnabled

            self.symbolsTextField.isEnabled = controlsAreEnabled
            self.symbolsButton.isEnabled = controlsAreEnabled

            self.outputCrashTextField.isEnabled = controlsAreEnabled
            self.outputCrashButton.isEnabled = controlsAreEnabled
        }

//        symbolicateButton.isEnabled = viewModel.symbolicateButtonIsEnabled
    }

    // MARK: Symbolicate
    private func symbolicate() {
//        viewModel.progressIsStarted = true
//        updateUI()

//        symbolicateCrashService.symbolicateCrash(symbolicateCrashInfo, qos: .userInitiated) { [weak self] error in
//            guard let this = self else {
//                return
//            }
//
//            if let error = error {
//                this.viewModel.errorMessage = "Error: \(error)"
//            } else {
//                this.viewModel.errorMessage = ""
//                this.openFinderAndSelectFile(this.symbolicateCrashInfo.outputCrash)
//            }
//
//            this.viewModel.progressIsStarted = false
//            this.updateUI()
//        }
    }

    private func makeOutputCrashLogPath(from inputCrashLogPath: String) -> String {
        let inputCrashLogURL = URL(fileURLWithPath: inputCrashLogPath)
        let fileExtension = "." + inputCrashLogURL.pathExtension

        var outputCrashLogName = inputCrashLogURL.lastPathComponent
        if let fileExtensionRange = outputCrashLogName.range(of: fileExtension) {
            outputCrashLogName.removeSubrange(fileExtensionRange)
        }

        return ""
//        return viewModel.outputCrashLogPath + "/\(outputCrashLogName + "-symbolicated").crash"
    }

}

// MARK: - Protocol NSTextFieldDelegate

extension MainViewController: NSTextFieldDelegate {

    func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return
        }

//        let newValue = textField.stringValue
//
//        if textField === inputCrashTextField {
//            viewModel.inputCrashLogPath = newValue
//        }
//        else if textField === symbolsTextField {
//            viewModel.symbolsPath = newValue
//        }
//        else if textField === outputCrashTextField {
//            viewModel.outputCrashLogPath = newValue
//        }
//
//        updateUI()
    }

}
