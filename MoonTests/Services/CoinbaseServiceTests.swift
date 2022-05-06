//
//  CoinbaseServiceTests.swift
//  MoonTests
//
//  Created by Ludovic Roullier on 25/04/2022.
//

import XCTest
@testable import Moon

class CoinbaseServiceTests: XCTestCase {

	var coinbaseService: CoinbaseServiceProtocol?
	
	override func setUpWithError() throws {
		self.coinbaseService = CoinbaseService()
	}
	
	override func tearDownWithError() throws {
		coinbaseService = nil
	}
	
	func testFetchFiatPrice() {
		
		let currencyCode = "USD"
		let expect = XCTestExpectation(description: "callback")
		
		coinbaseService?.getFiatPrice(currencyCode) { result in
			expect.fulfill()
		
			switch result {
			case .success(let value):
				
				XCTAssertNotNil(value)
				
				let currentValue = Double(value.data.amount ?? "0.0") ?? 0.0
				XCTAssertGreaterThan(currentValue, 2000.0)
				
			case .failure(let error):
				
				XCTFail("Error getFiatPrice : \(error)")
			}
		}
		
		wait(for: [expect], timeout: 5.0)
	}
}
