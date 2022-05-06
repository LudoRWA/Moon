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

	func testFetchAssets() {
		
		let wallet = "0x1b584fc86390d7D83B529a4346330ee3D2061681" //Wallet with four assets
		let expect = XCTestExpectation(description: "callback")
		
		openSeaService?.getAssets(50, wallet, nil, completion: { (result) in
			expect.fulfill()
			
			switch result {
			case .success(let value):
				
				XCTAssertNotNil(value)
				XCTAssertEqual(value.assets.count, 4)
				
				for asset in value.assets {
					XCTAssertNotNil(asset.collection.slug)
				}
				
			case .failure(let error):
				
				XCTFail("Error getAssets : \(error)")
			}
		})
		
		wait(for: [expect], timeout: 5.0)
	}
	
	func testFetchCollections() {
		
		let collectionSlug = "the-doge-pound" //valid collectionSlug, floorPrice always > 0.00
		let expect = XCTestExpectation(description: "callback")
		
		openSeaService?.getCollection(collectionSlug, completion: { (result) in
			expect.fulfill()
			
			switch result {
			case .success(let value):
				
				XCTAssertNotNil(value)
				XCTAssertNotEqual(value.collection.stats.floor_price, 0)
				
			case .failure(let error):
				
				XCTFail("Error getCollection : \(error)")
			}
		})
		
		wait(for: [expect], timeout: 5.0)
	}
}
