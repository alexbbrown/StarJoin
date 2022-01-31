//
//  ScaleTests.swift
//  StarJoinSelectorTests
//
//  Created by alex on 7/19/17.
//  Copyright © 2017 apple. All rights reserved.
//

import XCTest
@testable import StarJoinSelector

//  Originally:
//  ScaleTests.swift
//  ScaleTests
//
//  Created by alex on 21/08/2014.
//
//

public let ordinalScalesEnabled = false

class ScaleLinearTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLinearBasic() {
        // This is an example of a functional test case.

        let lin = LinearScale<Float>(domain: [0,1],range: (1000,2000))

        XCTAssertEqual(1000,lin.scale(0)!)
        XCTAssertEqual(1500,lin.scale(0.5)!)
        XCTAssertEqual(2000,lin.scale(1)!)
        XCTAssertEqual(3000,lin.scale(2)!)
        // XCTAssertNil(lin.scale(Float.NaN)) // xctest is not telling me what's going on

    }

    func testLinearBasic100() {
        // This is an example of a functional test case.

        let lin = LinearScale<Float>(domain: [0,100],range: (1000,2000))

        XCTAssertEqual(1000,lin.scale(0)!)
        XCTAssertEqual(1500,lin.scale(50)!)
        XCTAssertEqual(2000,lin.scale(100)!)
        XCTAssertEqual(3000,lin.scale(200)!)
        // XCTAssertNil(lin.scale(Float.NaN)) // xctest is not telling me what's going on

    }

    func testLinearBasic10() {
        // This is an example of a functional test case.

        let lin = LinearScale<Float>(domain: [0,10],range: (1000,2000))

        XCTAssertEqual(1000,lin.scale(0)!)
        XCTAssertEqual(1500,lin.scale(5)!)
        XCTAssertEqual(2000,lin.scale(10)!)
        XCTAssertEqual(3000,lin.scale(20)!)
        // XCTAssertNil(lin.scale(Float.NaN)) // xctest is not telling me what's going on

    }

    func testLinearBasic001() {
        // This is an example of a functional test case.

        let lin = LinearScale<Float>(domain: [0,0.01],range: (1000,2000))

        XCTAssertEqual(1000,lin.scale(0.0)!)
        XCTAssertEqual(1500,lin.scale(0.005)!)
        XCTAssertEqual(2000,lin.scale(0.01)!)
        XCTAssertEqual(3000,lin.scale(0.02)!)
        // XCTAssertNil(lin.scale(Float.NaN)) // xctest is not telling me what's going on

    }

    func testTicks() {

        let lin = LinearScale<Float>(domain: [0,1.0],range: (-100,100))

        let ticks = lin.ticks(3)

        XCTAssertEqual([0.0, 0.5, 1.0], ticks)

    }

    #if ordinalScalesEnabled
    func testOrdinalBasic() {

        let domain = ["Alex","Bob","Joe"]

        let ord = OrdinalScale<String,Float>(domain:domain, range:(0.0,100.0))

        XCTAssertEqual(0,ord.scale("Alex")!)
        XCTAssertEqual(50,ord.scale("Bob")!)
        XCTAssertEqual(100,ord.scale("Joe")!)
        XCTAssertNil(ord.scale("Jerry"))
    }

    func testOrdinalBasicObject() {

        let domain = ["Alex","Bob","Joe"]

        let bn1 = NSNumber(value: -4395844688870694692 as Int64)
        let bn2 = NSNumber(value: 5728683087421973059 as Int64)
        let bz = NSNumber(value: 0 as Int64)

        let dict:NSArray = [["a":bn1], ["a":bn2], ["a":bz]]
        let list = [bn1,bn2,bz]
        let d2 = dict as! [[String:NSObject]]
        let vs = d2.map({$0["a"]!})

        print("h: \(vs.index(of: bn2))")
        print("h: \(vs.index(of: bn1))")
        print("h: \(vs.index(of: bz))")

        print("h: \(list.index(of: bn2))")
        print("h: \(list.index(of: bn1))")
        print("h: \(list.index(of: bz))")

        //        let hoo = dict.valueForKeyPath("a")

        //
        //        if let hoo = hoo as? [NSObject] {
        //            println("h2: \(find(hoo,bn2))")
        //            println("h2: \(find(hoo,bn1))")
        //            println("h2: \(find(hoo,bz))")
        //        }


        let ord = OrdinalScale<NSObject,Float>(domain:Array(vs), range:(0.0,100.0))

        print("a: \(ord.scale(bn1))")
        print("b: \(ord.scale(bn2))")
        print("c: \(ord.scale(bz))")

        XCTAssertEqual(0,ord.scale(bz)!)
        XCTAssertEqual(0,ord.scale(NSNumber(value: 0 as Int32))!)
        XCTAssertEqual(0,ord.scale(bn1)!)
        XCTAssertEqual(0,ord.scale(bn2)!)


    }

    func testOrdinalRangeBands() {

        let domain = ["Alex","Bob"]

        let ord = OrdinalRangeBandsScale<String,Float>(domain:domain, range:(0.0,100.0))

        XCTAssertEqual(25,ord.scale("Alex")!)
        XCTAssertEqual(75,ord.scale("Bob")!)
        XCTAssertNil(ord.scale("Jerry"))

        XCTAssertEqual(0.0,ord.band("Alex")!.left)
        XCTAssertEqual(50.0,ord.band("Alex")!.right)
        XCTAssertEqual(50.0,ord.band("Bob")!.left)
        XCTAssertEqual(100.0,ord.band("Bob")!.right)

        //XCTAssertEqual(100,ord.scale("Joe"))
        XCTAssertNil(ord.scale("Jerry"))
    }

    func testWeightedOrdinalRangeBands() {

        let domain = ["Alex","Bob","Joe"]
        let weights:[Float] = [0,1,4]

        let ord = WeightedOrdinalRangeBandsScale<String,Float>(domain:domain, range:(0.0,100.0), weights:weights)

        XCTAssertEqual(0,ord.scale("Alex")!)
        XCTAssertEqual(10,ord.scale("Bob")!)
        XCTAssertEqual(60,ord.scale("Joe")!)

        XCTAssertNil(ord.scale("Jerry"))

        XCTAssertEqual(0.0,ord.band("Alex")!.left)
        XCTAssertEqual(0.0,ord.band("Alex")!.right)
        XCTAssertEqual(0.0,ord.band("Bob")!.left)
        XCTAssertEqual(20.0,ord.band("Bob")!.right)
        XCTAssertEqual(20.0,ord.band("Joe")!.left)
        XCTAssertEqual(100.0,ord.band("Joe")!.right)

        XCTAssertEqual(0.0,ord.bandWidth("Alex")!)
        XCTAssertEqual(20.0,ord.bandWidth("Bob")!)
        XCTAssertEqual(80.0,ord.bandWidth("Joe")!)

        //XCTAssertEqual(100,ord.scale("Joe"))
        XCTAssertNil(ord.scale("Jerry"))
    }



    //    func testOrdinalEdgeCases() {
    //
    //        let domain = [String]()
    //
    //        let ord = OrdinalScale<String,Float>()
    //
    //        ord.domain(domain)
    //        ord.range((0,100))
    //
    //        XCTAssertEqual(0,ord.scale("Alex"))
    //        XCTAssertEqual(50,ord.scale("Bob"))
    //        XCTAssertEqual(100,ord.scale("Joe"))
    //        XCTAssertNil(ord.scale("Jerry"))
    //    }

    #endif

}

