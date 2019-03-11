//
//  RestHelper.swift
//  CheckIn
//
//  Created by Anand Kelkar on 03/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation

public class RestHelper {
    
    static var schoolName = ""
    static let host = "https://dev1-ljff.cs65.force.com/test/services/apexrest"
    static let urls = [
        "Register_Device":host+"/device/register",
        "Get_Registration_Key":host+"/device",
        "Get_Events":host+"/event",
        "Get_Schools":host+"/schools",
        "Get_Students":host+"/students",
        "Attendance":host+"/event/attendance",
        "Create_Event":host+"/createEvent",
        "Get_Students_By_School":host+"/schools/" + schoolName] as Dictionary<String,String>
    
    //Method to make POST REST call
    class func makePost(_ url:URL, _ params: Dictionary<String, String>) -> String {

        var jsonData = NSData()
        do {
            jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) as NSData
        } catch {
            print(error.localizedDescription)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(jsonData.length)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData as Data
        
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            return ("API call returned error: \(error)")
        }
        else {
//            print("Made Request, status code \(String(describing: response?.getStatusCode()))")
//            print(url)
//            print(String(data: request.httpBody!, encoding: String.Encoding.utf8)!)
            print(String(data: data!, encoding: String.Encoding.utf8)!)
//            print(error)
            return String(data: data!, encoding: String.Encoding.utf8)!
        }

    }
    
    
    //Method to make GET REST call
    class func makeGet(_ url:String, _ params: Dictionary<String, String>?) -> String {
        
        var request = URLRequest(url: URL(string: urls[url]!)!)
        request.httpMethod = "GET"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params as Any, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            return ("API call returned error: \(error)")
        }
        else {
            return String(data: data!, encoding: String.Encoding.utf8)!
        }
    }
    
}

//Extension to allow synchronous calls
extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}
