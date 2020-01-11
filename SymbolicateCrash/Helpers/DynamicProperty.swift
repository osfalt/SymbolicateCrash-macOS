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
    var listener: Listener?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    // MARK: - Init
    init(_ v: T) {
        value = v
    }

    // MARK: - Internal methods
    func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }

}
