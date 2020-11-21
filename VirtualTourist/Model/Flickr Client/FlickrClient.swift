//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Mikhail on 11/13/20.
//

import Foundation
import UIKit

class FlickrClient {
    static let apiKey = "3194bb2fc1fdd2005f32d51d2f4a3aae"
    
    enum Endpoints {
        static let baseUrl = "https://www.flickr.com/services/rest/"
        
        case searchPhotos(Pin)
        case getImage(String, String, String)
        
        var urlString: String {
            switch self {
            case .searchPhotos(let pin):
                return Endpoints.baseUrl + "?method=flickr.photos.search&api_key=\(FlickrClient.apiKey)&lat=\(pin.latitude)&lon=\(pin.longitude)&radius=0.1&sort=date-posted-desc&per_page=100&page=1&format=json&nojsoncallback=1"
            case .getImage(let id, let server, let secret):
                return "https://live.staticflickr.com/\(server)/\(id)_\(secret)_w.jpg"
            }
        }
        
        var url: URL {
            URL(string: urlString)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print(String(data: data, encoding: .utf8)!)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func searchPhotos(pin: Pin, completion: @escaping ([FlickrPhoto], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.searchPhotos(pin).url, responseType: SearchPhotosResponse.self) { (response, error) in
            guard let response = response else {
                completion([], error)
                return
            }
            completion(response.photos.photo, nil)
        }
    }
    
    class func getImage(id: String, serverId: String, secret: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getImage(id, serverId, secret).url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
}
