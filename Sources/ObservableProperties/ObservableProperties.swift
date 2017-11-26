//
//  ObservableProperties.swift
//  ObservablePropertiesPackageDescription
//
//  Created by Dimitry Zolotaryov on 2017-11-26.
//

import Foundation

/**
 
 An observable property is a wrapper around any Equatable value that notifies any
 observer when the value changes. It is similar to Objective-C's KVO system but
 for Swift.
 
 */
public class ObservableProperty<T> {
    
    public typealias ObserverFunction = (ObservableProperty<T>, T, T) -> Void
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func set(_ value: T) {
        self.value = value
    }
    
    public func get() -> T {
        return value
    }
    
    public func observe(observer: AnyObject, function: @escaping ObserverFunction) {
        let weakObserver = WeakObserver(observer)
        observers[weakObserver] = function
    }
    
    public func stopObserving(observer: AnyObject) {
        observers.removeValue(forKey: WeakObserver(observer))
    }
    
    // MARK: Private
    
    private var observers: [WeakObserver: ObserverFunction] = [:]
    
    private var value: T {
        didSet {
            notify(newValue: value, oldValue: oldValue)
        }
    }
    
    private func notify(newValue: T, oldValue: T) {
        // Keeps an eye out on any nil observers in the list for cleanup
        var foundNil: Bool = false
        
        for (weakObserver, observerFunction) in observers {
            if weakObserver.observer == nil {
                foundNil = true
            } else {
                observerFunction(self, newValue, oldValue)
            }
        }
        
        if foundNil {
            // Cleans up any nil observers
            observers = observers.filter { weakObserver, observerFunction in
                return weakObserver.observer != nil
            }
        }
    }
}

extension ObservableProperty where T: Equatable {
    
    public func setIfDifferent(_ newValue: T) {
        if self.value != newValue {
            self.value = newValue
        }
    }
}

