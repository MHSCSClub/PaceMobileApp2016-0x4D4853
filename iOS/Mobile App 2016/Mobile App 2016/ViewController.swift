//
//  ViewController.swift
//  API
//
//  Created by Jack Phillips on 3/4/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        File.writeFile("jack.txt", data: "Jack is so cool")
        let server = ServerConnection(url: "http://garlandphillips.net/testConn/filetest.php")
        server.connectionFile(NSData(contentsOfURL: NSURL(fileURLWithPath: File.getFilePath("jack.txt")))!, completion: OnFinish);
        let server2 = ServerConnection(url: "http://garlandphillips.net/testConn/test.php")
        let params = ["name":"cool", "name2":"Jack Phillips"]
        server2.postRequest(params, completion: Done)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    func OnFinish (data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
    }
    func Done (data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let data = json["data"] as? [[String: AnyObject]]{
                for info in data{
                    if let name = info["name"] as? String{
                        print("Name is \(name)");
                    }
                }
            }
        }
        catch {
            print("error serializing JSON: \(error)")
        }
    }
    
    
    
}

