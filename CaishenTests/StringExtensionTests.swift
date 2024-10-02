import XCTest
@testable import Caishen

final class StringExtensionTests: XCTestCase {
  func testIsNumeric() {
    XCTAssertTrue("0".isNumeric())
    XCTAssertTrue("1".isNumeric())
    XCTAssertFalse("1.5".isNumeric())
    XCTAssertFalse("a".isNumeric())
    XCTAssertFalse("1️⃣".isNumeric())
    XCTAssertFalse("🔥".isNumeric())
  }
}
