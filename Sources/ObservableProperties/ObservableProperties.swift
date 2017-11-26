//
//  ObservableProperties.swift
//  ObservablePropertiesPackageDescription
//
//  Created by Dimitry Zolotaryov on 2017-11-26.
//

import Foundation

public enum ObservablePropertyChangeType {
    /// Subscribing to a property also notifies the observer of the current value.
    case initial
    
    /// Observer is notified before the property is changed.
    case prior
    
    /// Default. Observer is notified after a property changes.
    case new
}

/**
 
 An observable property is a wrapper around any Equatable value that notifies any
 observer when the value changes. It is similar to Objective-C's KVO system but
 for Swift.
 
 Unlike the original KVO system, this Swift version always passes the old and the new
 values of the observed property. When passing `.initial`, both the old value and new
 value are the same: they are the current value.
 
 As well, unlike the original KVO system, properties do not support dot-notation
 observation. For instance, it's not possible to chain properties.
 
 */
public class ObservableProperty<T> {
    
    public typealias Element = T
    public typealias ObserverFunction = (ObservableProperty<Element>, ObservableChange) -> Void
    
    public struct ObservableChange {
        let changeType: ObservablePropertyChangeType
        let newValue: Element
        let oldValue: Element
        
        var isInitial: Bool { return changeType == .initial }
        var isPrior: Bool { return changeType == .prior }
        var isNew: Bool { return changeType == .new }
    }
    
    public struct ObserverProperties<Element> {
        let callback: ObserverFunction
        let changeTypes: Set<ObservablePropertyChangeType>
        let dispatchQueue: DispatchQueue?
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func set(_ value: T) {
        self.value = value
    }
    
    public func get() -> T {
        return value
    }
    
    public func observe(
        observer: AnyObject,
        changeTypes: [ObservablePropertyChangeType] = [.new],
        onQueue dispatchQueue: DispatchQueue? = nil,
        callback: @escaping ObserverFunction)
    {
        let weakObserver = WeakObserver(observer)
        observers[weakObserver] = ObserverProperties(callback: callback, changeTypes: Set(changeTypes), dispatchQueue: dispatchQueue)
        
        if changeTypes.contains(.initial) {
            callback(self, ObservableChange(changeType: .initial, newValue: value, oldValue: value))
        }
    }
    
    public func stopObserving(observer: AnyObject) {
        observers.removeValue(forKey: WeakObserver(observer))
    }
    
    // MARK: Private
    
    private var observers: [WeakObserver: ObserverProperties<Element>] = [:]
    
    private var value: T {
        willSet {
            notify(newValue: newValue, oldValue: value, changeType: .prior)
        }
        didSet {
            notify(newValue: value, oldValue: oldValue, changeType: .new)
        }
    }
    
    private func notify(newValue: T, oldValue: T, changeType: ObservablePropertyChangeType = .new) {
        guard observers.count > 0 else { return }
        
        // Keeps an eye out on any nil observers in the list for cleanup
        var foundNilObserver: Bool = false
        
        var change: ObservableChange? = nil
        for (weakObserver, observerProperties) in observers {
            guard weakObserver.observer != nil else {
                foundNilObserver = false
                continue
            }
            
            if observerProperties.changeTypes.contains(changeType) {
                if change == nil {
                    change = ObservableChange(
                        changeType: changeType,
                        newValue: newValue,
                        oldValue: oldValue)
                }
                
                if let dispatchQueue = observerProperties.dispatchQueue {
                    dispatchQueue.async {
                        observerProperties.callback(self, change!)
                    }
                } else {
                    observerProperties.callback(self, change!)
                }
            }
        }
        
        // Cleans up any nil observers
        if foundNilObserver {
            observers = observers.filter { weakObserver, observerFunction in
                return weakObserver.observer != nil
            }
        }
    }
}

// MARK: Equatable

extension ObservableProperty: Equatable {
    
    public static func ==(lhs: ObservableProperty, rhs: ObservableProperty) -> Bool {
        return lhs === rhs
    }
}

// MARK: T: Equatable

extension ObservableProperty where T: Equatable {
    
    public func setIfDifferent(_ newValue: T) {
        if self.value != newValue {
            self.value = newValue
        }
    }
}
