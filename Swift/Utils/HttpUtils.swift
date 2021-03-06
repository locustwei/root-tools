//
//  HttpUtils.swift
//  YuGiOhCard
//
//  Created by rarnu on 9/30/14.
//  Copyright (c) 2014 rarnu. All rights reserved.
//

import UIKit

@objc
protocol HttpUtilsDelegate: NSObjectProtocol {
    optional func httpUtils(httpUtils:HttpUtils, receivedData data: NSData?)
    optional func httpUtils(httpUtils:HttpUtils, receivedError err: NSString)
    optional func httpUtils(httpUtils:HttpUtils, receivedFileSize fileSize: Int64)
    optional func httpUtils(httpUtils:HttpUtils, receivedProgress progress: Int)
}

class HttpUtils: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    var receivedData: NSMutableData?
    var delegate: HttpUtilsDelegate?
    
    func get(url: String) {
        NSLog(url)
        var u = NSURL(string: url)
        var req = NSURLRequest(URL: u!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
        var conn = NSURLConnection(request: req, delegate: self)
        conn!.start()
    }
    
    func post(url: String, param: String) {
        var u = NSURL(string: url)
        var req = NSMutableURLRequest(URL: u!)
        req.HTTPMethod = "POST"
        req.timeoutInterval = 60
        var data = (param as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        req.HTTPBody = data
        var conn = NSURLConnection(request: req, delegate: self)
        conn!.start()
    }
    
    func postFile(url: String, param: NSDictionary?, fieldName: String, fileName: String, mimeType: String, file: NSData) {
        // TODO: post upload file
        
        var prefix = "--"
        var suffix = "22b996c312d6"
        var boundary = prefix + suffix
        
        // NSString *name = [params objectForKey:@"name"]; // fieldname
        // NSString *fileName = [params objectForKey:@"fileName"]; // filename
        // NSString *type = [params objectForKey:@"type"];  // mimetype
        
        var topStr = ""
        topStr += "\(boundary)\r\n"
        topStr += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"; "
        if (param != nil) {
            var keys = param!.allKeys
            for s in keys {
                var key = s as String
                topStr += "\(key)=\"\(param!.objectForKey(key) as String)\"; "
            }
        }
        topStr += "\r\n"
        topStr += "Content-Type: \(mimeType)\r\n\r\n"
        
        var bottomStr = ""
        bottomStr += "\r\n\(boundary)--"
        
        var dataP = NSMutableData()
        dataP.appendData(topStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)!)
        dataP.appendData(file)
        dataP.appendData(bottomStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        var u = NSURL(string: url)
        var request = NSMutableURLRequest(URL: u!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
        request.HTTPBody = dataP
        request.HTTPMethod = "POST"
        
        var stringLength = "\(dataP.length)"
        request.setValue(stringLength, forHTTPHeaderField: "Content-Length")
        
        var stringContentType = "multipart/form-data; boundary=\(suffix)"
        request.setValue(stringContentType, forHTTPHeaderField: "Content-Type")
        
        var connection = NSURLConnection(request: request, delegate: self)
        connection!.start()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.receivedData!.appendData(data)
        self.delegate?.httpUtils?(self, receivedProgress: self.receivedData!.length)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.receivedData = NSMutableData()
        self.delegate?.httpUtils?(self, receivedFileSize: response.expectedContentLength)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.delegate?.httpUtils?(self, receivedData: self.receivedData)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        NSLog(error.localizedDescription)
        self.delegate?.httpUtils?(self, receivedError: error.localizedDescription)
    }
    
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool {
        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            challenge.sender.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust), forAuthenticationChallenge: challenge)
        }
        challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
    }
    
}
