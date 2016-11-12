//
//  ApiKeys.swift
//  zillowGun
//
//  Created by Anne Maiale on 11/12/16.
//  Copyright © 2016 Anne Maiale. All rights reserved.
//

import Foundation

var apiKey = String();

func valueForAPIKey(named keyname:String) -> String {
    // Credit to the original source for this technique at
    // http://blog.lazerwalker.com/blog/2014/05/14/handling-private-api-keys-in-open-source-ios-apps
    if !apiKey.isEmpty { return apiKey }
    let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
    print(filePath)
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    apiKey = value
    return apiKey
}
