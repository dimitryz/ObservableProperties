import XCTest

@testable import ObservableProperties

class Observer {}

class ObservablePropertiesTests: XCTestCase {
    
    func testBooleanValue() {
        let expectation = self.expectation(description: "New value should equal true")
        
        let booleanProperty = ObservableProperty<Bool>(false)
        booleanProperty.observe(observer: self) { [weak expectation] (property, newValue, oldValue) in
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
        arrayProperty.observe(observer: self) { [weak expectation] (property, newValue, oldValue) in
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
        
        let intProperty = ObservableProperty<Int>(1)
        intProperty.observe(observer: self) { (property, newValue, oldValue) in
            counter -= 1
        }
        
        intProperty.setIfDifferent(2)
        intProperty.setIfDifferent(2)
        
        XCTAssert(counter == 0)
    }
}
