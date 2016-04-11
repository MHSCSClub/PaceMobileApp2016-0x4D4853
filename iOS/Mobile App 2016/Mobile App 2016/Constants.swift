//
//  Constants.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/13/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import Foundation

class Constants{
    //http://108.30.55.167
    static let baseURL = "http://ec2-54-213-18-197.us-west-2.compute.amazonaws.com"
    
    static func getAuthCode() -> String{
        return File.readFile("authcode");
    }
    static func saveAuthCode(authcode: String){
        File.writeFile("authcode", data: authcode)
    }
    static func saveType(type: String){
        File.writeFile("type", data: type)
    }
    static func getType() -> String {
        return File.readFile("type")
    }
}