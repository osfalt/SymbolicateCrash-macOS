//
//  MainRouter.swift
//  SymbolicateCrash
//
//  Created by Dre on 11.01.2020.
//  Copyright © 2020 Andrey Sidorovnin. All rights reserved.
//

import AppKit

// MARK: - Protocol
protocol MainRouterProtocol: AnyObject {

    typealias OpenPanelCompletion = (_ fileURL: URL) -> Void

    func openPanelForInputCrashLog(completion: OpenPanelCompletion)
    func openPanelForSymbols(completion: OpenPanelCompletion)
    func openPanelForOutputCrashLog(completion: OpenPanelCompletion)
    func openFinderAndSelectFile(at path: String)
    
}

// MARK: - Implementation
class MainRouter: MainRouterProtocol {

    // MARK: - Constants
    private enum PanelMessage {
        static let inputCrash = "Choose a crash log file"
        static let symbols = "Choose a dSYM file or folder"
        static let outputCrash = "Choose a symbolicated crash log path"
    }

    // MARK: - Internal methods
    func openPanelForInputCrashLog(completion: OpenPanelCompletion) {
        chooseFile(message: PanelMessage.inputCrash,
                   canChooseDirs: false,
                   allowedFileTypes: ["crash"],
                   completion: completion)
    }

    func openPanelForSymbols(completion: OpenPanelCompletion) {
        chooseFile(message: PanelMessage.symbols,
                   canChooseDirs: true,
                   completion: completion)
    }

    func openPanelForOutputCrashLog(completion: OpenPanelCompletion) {
        chooseFile(message: PanelMessage.outputCrash,
                   canChooseDirs: true,
                   completion: completion)
    }

    func openFinderAndSelectFile(at path: String) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }

    // MARK: - Private methods
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

}
