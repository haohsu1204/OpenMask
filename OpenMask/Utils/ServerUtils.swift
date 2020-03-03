//
//  ServerUtils.swift
//  OpenMask
//
//  Created by House on 2020/2/7.
//  Copyright © 2020 haohsu. All rights reserved.
//

import Foundation
import Alamofire

class ServerUtils {
    
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }
    
    static func request<T: Any>(url :String,method: HTTPMethod, params :Dictionary<String,Encodable>?,requestComplete: @escaping (_ success: Bool, _ message: String, _ data: T?) -> Void) {
        
        let wrappedDict = params?.mapValues(EncodableWrapper.init(wrapped:))
        AF.request(url, method: method, parameters: wrappedDict, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in

            var status :Int = 500
            var message :String = ""
            var data :T? = nil

            switch response.result{
            case .success(let JSON):
                #if DEBUG
                //print("Success with JSON: \(JSON)")
                #endif
                
                let response = JSON as! [String: Any]
    
                if let value = response["status"] as? Int {
                    status = value
                }
                if let value = response["message"] as? String {
                    message = value
                }
                if let value = response["payload"] as? T {
                    data = value
                }
                
            case .failure(let error):
                #if DEBUG
                print("Request failed with error: \(error)")
                #endif
            }
            
            requestComplete(status == 200,message,data)
        }
    }
}
