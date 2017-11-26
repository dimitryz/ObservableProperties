import XCTest
@testable import ObservableProperties

class ObservablePropertiesTests: XCTestCase {
    
    func testBooleanValue() {
        let expectation = self.expectation(description: "New value should equal true")
        
        let booleanProperty = ObservableProperty(false)
        booleanProperty.observe(observer: self) { [weak expectation] (property, change) in
            XCTAssert(change.changeType == .new)
            XCTAssert(change.newValue)
            XCTAssertFalse(change.oldValue)
            expectation?.fulfill()
        }
        
        booleanProperty.set(true)
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testArrayValue() {
        let expectation = self.expectation(description: "New value should contain 1 element")
        
        let arrayProperty = ObservableProperty<[Int]>([])
        arrayProperty.observe(observer: self) { [weak expectation] (property, change) in
            XCTAssert(change.newValue.count == 1)
            expectation?.fulfill()
        }
        
        arrayProperty.set([1])
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testEqutableValue() {
        var counter = 1
        
        let intProperty = ObservableProperty(1)
        intProperty.observe(observer: self) { (property, change) in
            counter -= 1
        }
        
        intProperty.setIfDifferent(2)
        intProperty.setIfDifferent(2)
        
        XCTAssert(counter == 0)
    }
    
    func testEquality() {
        let aProperty = ObservableProperty(true)
        let bProperty = ObservableProperty(true)
        
        XCTAssertTrue(aProperty == aProperty)
        XCTAssertFalse(aProperty == bProperty)
    }
    
    func testInitialValue() {
        var counter = 2
        
        let property = ObservableProperty(1)
        property.observe(observer: self, changeTypes: [.initial, .new]) { (property, change) in
            if counter == 2 {
                XCTAssert(change.changeType == .initial)
            } else if counter == 1 {
                XCTAssert(change.changeType == .new)
            }
            
            counter = counter - 1
            
            XCTAssertEqual(change.newValue, change.oldValue)
        }
        property.set(1)
        
        XCTAssertEqual(counter, 0)
    }
    
    func testRemoveObserver() {
        var counter = 0
        let property = ObservableProperty(true)
        property.observe(observer: self) { (property, change) in
            counter = counter - 1
        }
        property.stopObserving(observer: self)
        XCTAssertEqual(counter, 0)
    }
    
    func testNewAndPriorObserver() {
        var counter = 2
        let property = ObservableProperty(true)
        property.observe(observer: self, changeTypes: [.new, .prior]) { (property, change) in
            if counter == 2 {
                XCTAssert(change.changeType == .prior)
            } else if counter == 1 {
                XCTAssert(change.changeType == .new)
            }
            counter = counter - 1
        }
        property.set(false)
        XCTAssertEqual(counter, 0)
    }
}
