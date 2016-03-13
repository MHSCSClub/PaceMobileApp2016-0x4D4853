//
//  ServerFile.swift
//  
//
//  Created by Jack Phillips on 6/25/15.
//
//
/*
This class Does server Push request
init with a String repersenting the URL you want to go to
func connectionFile(data: NSData) -> NSData | this is for uploading files | mp4
*/

import Foundation

class ServerConnection {
    
    static func postRequest(params: [String: String], url: String, completion: ((data: NSData) -> Void)!) -> Void{
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        var bodyData = ""
        for (name, value) in params{
            bodyData += "\(name)=\(value)&"
        }
        bodyData.removeAtIndex(bodyData.endIndex.predecessor())
        
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if(data != nil){
                completion(data: data!)
            }else{
                print(error)
            }
            
        })
        task.resume()
        

    }
    static func getRequest(url: String, completion: ((data: NSData) -> Void)!) -> Void{
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if(data != nil){
                completion(data: data!)
            }else{
                print(error)
            }
            
            
        })
        task.resume()
        
        
    }
    
    static func postFile(data: NSData, url: String, completion: ((data: NSData) -> Void)!) -> Void {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        let boundary = NSString(format: "---------------------------14737809831466499882746641449")
        let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        //  println("Content Type \(contentType)")
        request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format:"Content-Disposition: form-data; name=\"file\"; filename=\"test.m4a\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(data)
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        request.HTTPBody = body
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if(data != nil){
                completion(data: data!)
            }else{
                print(error)
            }
            
            
        })
        task.resume()
        
        
    }
    
}