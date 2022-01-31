//
//  SampleData.swift
//  SpriteJoinSampleData
//
//  Created by apple on 24/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

//https://developer.yahoo.com/yql/console/?q=select%20%2a%20from%20yahoo.finance.historicaldata%20where%20symbol%20in%20%28%27YHOO%27%29%20and%20startDate%20=%20%272009-09-11%27%20and%20endDate%20=%20%272010-03-10%27&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys#h=select+*+from+yahoo.finance.historicaldata+where+symbol+in+(%22GOOG%22)+and+startDate+%3D+'2013-01-01'+and+endDate+%3D+'2014-01-01'

//http://www.jarloo.com/google-finance-and-yql/

import Foundation

private class BundleFinder {}

public func sampleDataJSON(name:String) throws -> NSDictionary? {
    let bundle = Bundle(for: BundleFinder.self)

    if let url = bundle.url(forResource: name, withExtension:"json", subdirectory: "SampleData") {
        do {
            if let jsonData = NSData(contentsOf:url) {

                let jsonDict = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as? NSDictionary

                return jsonDict
            }
        }
    }
    return nil;

}

public func yahooHistorical(name:String) -> [[String:String]]? {

    do {
        if let query = try sampleDataJSON(name: name)?["query"] as? NSDictionary,
            let quote = (query["results"] as? NSDictionary)?["quote"] as? [[String:String]] {
            return quote
        }
        return nil
    } catch {
        return nil
    }
}

