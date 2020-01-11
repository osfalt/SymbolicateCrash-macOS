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

    private var inputCrashLogPathToken: String?
    private var symbolsPathToken: String?
    private var outputCrashLogPathToken: String?
    private var symbolicateButtonIsEnabledToken: String?
    private var errorMessageToken: String?
    private var progressIsStartedToken: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bindToViewModel()
    }

    deinit {
        viewModel.inputCrashLogPath.unbind(inputCrashLogPathToken)
        viewModel.symbolsPath.unbind(symbolsPathToken)
        viewModel.outputCrashLogPath.unbind(outputCrashLogPathToken)
        viewModel.errorMessage.unbind(errorMessageToken)
        viewModel.progressIsStarted.unbind(progressIsStartedToken)
        viewModel.symbolicateButtonIsEnabled.unbind(symbolicateButtonIsEnabledToken)
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
        inputCrashLogPathToken = viewModel.inputCrashLogPath.bind { [weak self] in
            self?.inputCrashTextField.stringValue = $0
        }

        symbolsPathToken = viewModel.symbolsPath.bind { [weak self] in
            self?.symbolsTextField.stringValue = $0
        }

        outputCrashLogPathToken = viewModel.outputCrashLogPath.bind { [weak self] in
            self?.outputCrashTextField.stringValue = $0
        }

        symbolicateButtonIsEnabledToken = viewModel.symbolicateButtonIsEnabled.bind { [weak self] in
            self?.symbolicateButton.isEnabled = $0
        }

        errorMessageToken = viewModel.errorMessage.bind { [weak self] errorMessage in
            guard let self = self else { return }
            self.errorLabel.isHidden = errorMessage == nil
            self.errorLabel.stringValue = errorMessage ?? ""
        }

        progressIsStartedToken = viewModel.progressIsStarted.bind { [weak self] progressIsStarted in
            guard let self = self else { return }

            progressIsStarted
                ? self.progressIndicator.startAnimation(nil)
                : self.progressIndicator.stopAnimation(nil)

            let controlsAreEnabled = !progressIsStarted
            self.inputCrashTextField.isEnabled = controlsAreEnabled
            self.inputCrashButton.isEnabled = controlsAreEnabled

            self.symbolsTextField.isEnabled = controlsAreEnabled
            self.symbolsButton.isEnabled = controlsAreEnabled

            self.outputCrashTextField.isEnabled = controlsAreEnabled
            self.outputCrashButton.isEnabled = controlsAreEnabled
        }
    }

}

// MARK: - Protocol NSTextFieldDelegate

extension MainViewController: NSTextFieldDelegate {

    func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return
        }

        let newValue = textField.stringValue

        if textField === inputCrashTextField {
            viewModel.inputCrashLogPath.value = newValue
        } else if textField === symbolsTextField {
            viewModel.symbolsPath.value = newValue
        } else if textField === outputCrashTextField {
            viewModel.outputCrashLogPath.value = newValue
        }
    }

}
