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
            XCTAssertNil(error)
        }
    }
}
