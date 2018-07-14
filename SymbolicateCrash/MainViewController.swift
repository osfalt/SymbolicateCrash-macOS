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

    private typealias OpenPanelCompletion = (_ filePath: String) -> Void

    private enum PanelMessage {
        static let inputCrash = "Choose a crash log file"
        static let symbols = "Choose a dSYM file or folder"
        static let outputCrash = "Choose a symbolicated crash log path"
    }

    private struct ViewModel {
        var inputCrashLogPath = ""
        var symbolsPath = ""
        var outputCrashLogPath = ""
        var symbolicateButtonIsEnabled = false
    }

    // MARK: - Private properties

    @IBOutlet private weak var inputCrashTextField: NSTextField!
    @IBOutlet private weak var symbolsTextField: NSTextField!
    @IBOutlet private weak var outputCrashTextField: NSTextField!
    @IBOutlet private weak var symbolicateButton: NSButton!

    private var viewModel = ViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
        // Implement
    }

    // MARK: - Private methods

    private func updateUI() {
        inputCrashTextField.stringValue = viewModel.inputCrashLogPath
        symbolsTextField.stringValue = viewModel.symbolsPath
        outputCrashTextField.stringValue = viewModel.outputCrashLogPath
        symbolicateButton.isEnabled = viewModel.symbolicateButtonIsEnabled
    }

    private func chooseInputCrashLog() {
        chooseFile(message: PanelMessage.inputCrash,
                   canChooseDirs: false,
                   allowedFileTypes: ["crash"]) { filePath in
                    viewModel.inputCrashLogPath = filePath
                    updateUI()
        }
    }

    private func chooseSymbols() {
        chooseFile(message: PanelMessage.symbols,
                   canChooseDirs: true) { filePath in
                    viewModel.symbolsPath = filePath
                    updateUI()
        }
    }

    private func chooseOutputCrashLog() {
        chooseFile(message: PanelMessage.outputCrash,
                   canChooseDirs: true) { filePath in
                    viewModel.outputCrashLogPath = filePath
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
            let fileUrl = panel.url {
            completion(fileUrl.path)
        }
    }

}
