//
//  File.swift
//  Operator-iOS
//
//  Created by Jack Phillips on 6/26/15.
//  Copyright (c) 2015 Burke Rehabilitation. All rights reserved.
//

/*
The File Class Creates, Reads, and Writes to a File in an easier way to use.
Methods:
getFilePath(filename: String)
func readFile(filename: String) --> Returns String containing content of file
func writeFile(filename: String, data: String)
func writeFile(filename: String, data: NSData)
*/

import Foundation

class File {
    static func getFilePath(filename: String) -> String {
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
            let dir = dirs[0] //documents directory
            let path = (dir as NSString).stringByAppendingPathComponent(filename);
            return path;
    }
    
    static func readFile(filename: String) -> String {
        let filePath = getFilePath(filename);
        do{
            if(filePath != "ERROR"){
                return try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            }
        }
        catch{
        
            return "";
        }
        return "";
        
    }
    static func writeFile(filename: String, data: String){
        let filePath = getFilePath(filename);
        
        if(filePath != "ERROR"){
            do {
                try data.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
            } catch _ {
            };
        }
    }
    
    static func writeFile(filename: String, data: NSData){
        let filePath = getFilePath(filename);
        
        if(filePath != "ERROR"){
            data.writeToFile(filePath, atomically: true)
        }
    }
}