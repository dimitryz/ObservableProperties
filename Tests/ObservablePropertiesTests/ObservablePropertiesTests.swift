import XCTest
@testable import ObservableProperties

class ObservablePropertiesTests: XCTestCase {
    
    func testBooleanValue() {
        let expectation = self.expectation(description: "New value should equal true")
        
        let booleanProperty = ObservableProperty(false)
        booleanProperty.observe(observer: self) { [weak expectation] (property, newValue, oldValue, type) in
            XCTAssert(newValue)
            XCTAssertFalse(oldValue)
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
        arrayProperty.observe(observer: self) { [weak expectation] (property, newValue, oldValue, type) in
            XCTAssert(newValue.count == 1)
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
        intProperty.observe(observer: self) { (property, newValue, oldValue, type) in
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
        property.observe(observer: self, current: true) { (property, newValue, oldValue, changeType) in
            if counter == 2 {
                XCTAssertEqual(changeType, ObservablePropertyChangeType.initial)
            } else if counter == 1 {
                XCTAssertEqual(changeType, ObservablePropertyChangeType.new)
            }
            
            counter = counter - 1
            
            XCTAssertEqual(newValue, oldValue)
        }
        property.set(1)
        
        XCTAssertEqual(counter, 0)
    }
}
