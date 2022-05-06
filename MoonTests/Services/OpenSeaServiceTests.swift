//
//  MoonTests.swift
//  MoonTests
//
//  Created by Ludovic Roullier on 25/04/2022.
//

import XCTest
@testable import Moon

class OpenSeeaServiceTests: XCTestCase {

	var openSeaService: OpenSeaServiceProtocol?
	
	override func setUpWithError() throws {
		self.openSeaService = OpenSeaService()
    }

    override func tearDownWithError() throws {
		openSeaService = nil
    }

	func test_fetch_assets() {
		
		let wallet = "0x1b584fc86390d7D83B529a4346330ee3D2061681" //Wallet with four assets
		let expect = XCTestExpectation(description: "callback")
		
		openSeaService?.getAssets(50, wallet, nil, completion: { (value, statusCode) in
			expect.fulfill()
			
			XCTAssertNotNil(value)
			XCTAssertEqual(value?.assets.count, 4)
			XCTAssertEqual(statusCode, 200)
			
			for asset in value!.assets {
				XCTAssertNotNil(asset.collection.slug)
			}
		})
		
		wait(for: [expect], timeout: 5.0)
	}
	
	func test_fetch_collections() {
		
		let collection_slug = "the-doge-pound" //valid collection_slug, floor_price always > 0.00
		let expect = XCTestExpectation(description: "callback")
		
		openSeaService?.getCollection(collection_slug, completion: { (value) in
			expect.fulfill()
			
			XCTAssertNotNil(value)
			XCTAssertNotEqual(value?.collection.stats.floor_price, 0)
		})
		
		wait(for: [expect], timeout: 5.0)
	}
}
