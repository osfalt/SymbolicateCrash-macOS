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

    @IBOutlet private weak var inputCrashTextField: NSTextField!
    @IBOutlet private weak var symbolsTextField: NSTextField!
    @IBOutlet private weak var outputCrashTextField: NSTextField!
    @IBOutlet private weak var symbolicateButton: NSButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    }

    @IBAction
    private func selectSymbols(_ sender: NSButton) {

    }

    @IBAction
    private func selectOutputCrash(_ sender: NSButton) {

    }

    @IBAction
    private func symbolicateCrash(_ sender: NSButton) {

    }

}
