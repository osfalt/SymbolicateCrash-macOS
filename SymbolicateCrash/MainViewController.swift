//
//  MainViewController.swift
//  SymbolicateCrash
//
//  Created by Dre on 14/07/2018.
//  Copyright © 2018 Andrey Sidorovnin. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    // MARK: - Private types

    private typealias OpenPanelCompletion = (_ fileURL: URL) -> Void

    private enum PanelMessage {
        static let inputCrash = "Choose a crash log file"
        static let symbols = "Choose a dSYM file or folder"
        static let outputCrash = "Choose a symbolicated crash log path"
    }

    private struct ViewModel {

        var inputCrashLogPath = ""
        var symbolsPath = ""
        var outputCrashLogPath = ""
        var progressIsStarted = false
        var errorMessage = ""

        var symbolicateButtonIsEnabled: Bool {
            return !progressIsStarted && !inputCrashLogPath.isEmpty && !symbolsPath.isEmpty && !outputCrashLogPath.isEmpty
        }

    }

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

    private var viewModel = ViewModel()
    private var outputCrashPathWasChanged = false
    private let symbolicateCrashService = SymbolicateCrashService()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        updateUI()
    }

    // MARK: - Overrides

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // MARK: - Actions

    @IBAction
    private func selectInputCrash(_ sender: NSButton) {
        chooseInputCrashLog()
    }

    @IBAction
    private func selectSymbols(_ sender: NSButton) {
        chooseSymbols()
    }

    @IBAction
    private func selectOutputCrash(_ sender: NSButton) {
        chooseOutputCrashLog()
    }

    @IBAction
    private func symbolicateCrash(_ sender: NSButton) {
        symbolicate()
    }

    // MARK: - Private methods

    private func configure() {
        inputCrashTextField.delegate = self
        symbolsTextField.delegate = self
        outputCrashTextField.delegate = self
    }

    private func updateUI() {
        let controlsAreEnabled = !viewModel.progressIsStarted

        inputCrashTextField.stringValue = viewModel.inputCrashLogPath
        inputCrashTextField.isEnabled = controlsAreEnabled
        inputCrashButton.isEnabled = controlsAreEnabled

        symbolsTextField.stringValue = viewModel.symbolsPath
        symbolsTextField.isEnabled = controlsAreEnabled
        symbolsButton.isEnabled = controlsAreEnabled

        outputCrashTextField.stringValue = viewModel.outputCrashLogPath
        outputCrashTextField.isEnabled = controlsAreEnabled
        outputCrashButton.isEnabled = controlsAreEnabled

        symbolicateButton.keyEquivalent = "\r"
        symbolicateButton.isEnabled = viewModel.symbolicateButtonIsEnabled

        errorLabel.stringValue = viewModel.errorMessage
        errorLabel.isHidden = viewModel.errorMessage.isEmpty

        if viewModel.progressIsStarted {
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.stopAnimation(nil)
        }
    }

    // MARK: File Chooser

    private func chooseInputCrashLog() {
        chooseFile(message: PanelMessage.inputCrash,
                   canChooseDirs: false,
                   allowedFileTypes: ["crash"]) { fileURL in
                    viewModel.inputCrashLogPath = fileURL.path
                    if !outputCrashPathWasChanged {
                        viewModel.outputCrashLogPath = fileURL.deletingLastPathComponent().path
                    }
                    updateUI()
        }
    }

    private func chooseSymbols() {
        chooseFile(message: PanelMessage.symbols,
                   canChooseDirs: true) { fileURL in
                    viewModel.symbolsPath = fileURL.path
                    updateUI()
        }
    }

    private func chooseOutputCrashLog() {
        chooseFile(message: PanelMessage.outputCrash,
                   canChooseDirs: true) { fileURL in
                    outputCrashPathWasChanged = true
                    viewModel.outputCrashLogPath = fileURL.path
                    updateUI()
        }
    }

    private func chooseFile(message: String? = nil,
                            canChooseDirs: Bool,
                            allowedFileTypes: [String]? = nil,
                            completion: OpenPanelCompletion) {

        let panel = NSOpenPanel.make(message: message,
                                     canChooseDirectories: canChooseDirs,
                                     allowedFileTypes: allowedFileTypes)

        panel.animationBehavior = .alertPanel
        panel.orderFront(nil)

        let modalResponse = panel.runModal()
        if modalResponse == NSApplication.ModalResponse.OK,
            let fileURL = panel.url {
            completion(fileURL)
        }
    }

    // MARK: Sybolicate

    private func symbolicate() {
        viewModel.progressIsStarted = true
        updateUI()

        DispatchQueue.global(qos: .userInitiated).async {
            let inputCrashLogPath = self.viewModel.inputCrashLogPath
            let symbolsPath = self.viewModel.symbolsPath
            let outputCrashLogPath = self.makeOutputCrashLogPath(from: inputCrashLogPath)

            self.symbolicateCrashService.symbolicateCrash(inputCrashLogPath,
                                                          symbols: symbolsPath,
                                                          output: outputCrashLogPath)
            DispatchQueue.main.async {
                self.viewModel.progressIsStarted = false
                self.updateUI()
                self.openFinderAndSelectFile(outputCrashLogPath)
            }
        }
    }

    private func makeOutputCrashLogPath(from inputCrashLogPath: String) -> String {
        let inputCrashLogURL = URL(fileURLWithPath: inputCrashLogPath)
        let fileExtension = "." + inputCrashLogURL.pathExtension

        var outputCrashLogName = inputCrashLogURL.lastPathComponent
        if let fileExtensionRange = outputCrashLogName.range(of: fileExtension) {
            outputCrashLogName.removeSubrange(fileExtensionRange)
        }

        return viewModel.outputCrashLogPath + "/\(outputCrashLogName + "-symbolicated").crash"
    }

    private func openFinderAndSelectFile(_ path: String) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }

}

// MARK: - Protocol NSTextFieldDelegate

extension MainViewController: NSTextFieldDelegate {

    override func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return
        }

        let newValue = textField.stringValue

        if textField === inputCrashTextField {
            viewModel.inputCrashLogPath = newValue
        }
        else if textField === symbolsTextField {
            viewModel.symbolsPath = newValue
        }
        else if textField === outputCrashTextField {
            viewModel.outputCrashLogPath = newValue
        }

        updateUI()
    }

}
