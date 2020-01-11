//
//  DynamicProperty.swift
//  SymbolicateCrash
//
//  Created by Dre on 11.01.2020.
//  Copyright © 2020 Andrey Sidorovnin. All rights reserved.
//

import Foundation

class DynamicProperty<T> {

    // MARK: - Internal types
    typealias Listener = (T) -> Void

    // MARK: - Internal properties
    var value: T {
        didSet {
            listeners.values.forEach { $0(value) }
        }
    }

    // MARK: - Private properties
    private var listeners: [String: Listener] = [:]

    // MARK: - Init
    init(_ value: T) {
        self.value = value
    }

    // MARK: - Internal methods
    @discardableResult
    func bind(_ listener: @escaping Listener) -> String {
        let token = UUID().uuidString
        listeners[token] = listener
        listener(value)
        return token
    }

    func unbind(_ token: String?) {
        guard let token = token else { return }
        listeners.removeValue(forKey: token)
    }

    func unbindAll() {
        listeners.removeAll()
    }

}
