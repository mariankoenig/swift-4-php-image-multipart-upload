//
//  imageupload.swift
//
//  Created by Marian König on 20.04.18.
//  Copyright © 2018 none. All rights reserved.
//

import Foundation

func upload(image : UIImage, with modelName: String, completionHandler: @escaping ((Bool,String)->Void)){
    
    let url = URL(string: "_____/upload.php")
    
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "POST"
    
    let boundary = generateBoundaryString()
    
    request.setValue("multipart/form-data; boundary=\(boundary)",forHTTPHeaderField: "Content-Type")
    
    let image_data = UIImagePNGRepresentation(image)
    
    guard image_data != nil else {
        return
    }
    
    let body = NSMutableData()
    
    let fname = "\(modelName).png"
    
    let contentType = "multipart/form-data; boundary=\(boundary)"
    
    let mimetype = "image/png"
    
    /*
     body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
     body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
     body.append("hi\r\n".data(using: String.Encoding.utf8)!)
     */
    
    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
    body.append(image_data!)
    body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
    
    request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
    request.httpBody = body as Data
    
    let session = URLSession.shared
    
    let uploadTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
        
        guard error == nil else {
            print("error while uploadTask \(String(describing: error))")
            completionHandler(false,"error while uploadTask \(error.debugDescription).")
            return
        }
        
        guard data != nil else {
            print("no data at uploadTask")
            completionHandler(false,"Got no response from Imagecloud.")
            return
        }
        
        if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
            
            if dataString == "success"{
                completionHandler(true,"The model was successfully stored in the Imagecloud.")
            } else {
                completionHandler(false,String(dataString))
            }
        }
    })
    
    uploadTask.resume()
}


func generateBoundaryString() -> String
{
    return "Boundary-\(UUID().uuidString)"
}
