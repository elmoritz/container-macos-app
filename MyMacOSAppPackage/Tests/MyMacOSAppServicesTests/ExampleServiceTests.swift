import XCTest
import MyMacOSAppServices

final class ExampleServiceTests: XCTestCase {
    func testDoSomething() {
        let service = ExampleService()
        XCTAssertEqual(service.doSomething(), "Service did something!")
    }
}
