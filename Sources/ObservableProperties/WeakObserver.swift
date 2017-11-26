//
//  WeakObserver.swift
//  ObservablePropertiesPackageDescription
//
//  Created by Dimitry Zolotaryov on 2017-11-26.
//

import Foundation

class WeakObserver: Hashable {
    
    weak var observer: AnyObject?
    
    var hashValue: Int {
        return observer?.hashValue ?? -1
    }
    
    init(_ value: AnyObject) {
        self.observer = value
    }
    
    static func ==(lhs: WeakObserver, rhs: WeakObserver) -> Bool {
        return lhs.observer != nil && rhs.observer != nil && lhs.hashValue == rhs.hashValue
    }
}
