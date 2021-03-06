//
//  ViewController+CheckDistance.swift
//  HireDev
//
//  Created by Jeff Eom on 2016-10-04.
//  Copyright © 2016 Jeff Eom. All rights reserved.
//

import UIKit

extension UIViewController{
  func checkDistance(_ origin: String, destination: String, completion: @escaping (_ fetchedData: [Float]?) -> ()){
    var measuredDistances: [Float] = []
    
    var keys: NSDictionary?
    
    if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
      keys = NSDictionary(contentsOfFile: path)
    }
    if let dict = keys {
      let api = dict["googleDistance"] as? String
      
      let url : String = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(origin)&destinations=\(destination)&key=\(api!)"
      let urlStr: String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      
      let requestURL: URL = URL(string: urlStr)!
      
      let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
      let session = URLSession.shared
      
      let task = session.dataTask(with: urlRequest as URLRequest) {
        (data, response, error) -> Void in
        
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        if (statusCode == 200) {
          do{
            let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String: Any]
            
            if let rows = json?["rows"] as? [[String: Any]] {
              for aRow in rows {
                if let elements = aRow["elements"] as? [[String: Any]] {
                  for aElement in elements{
                    if let distance = aElement["distance"] as? [String: Any]{
                      measuredDistances.append(distance["value"]! as! Float)
                    }
                  }
                  DispatchQueue.main.async {
                    completion(measuredDistances)
                  }
                }
              }
            }
          }catch {
            print("Error with Json: \(error)")
          }
        }
      }
      task.resume()
    }
  }
}

