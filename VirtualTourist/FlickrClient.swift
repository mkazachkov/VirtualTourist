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
        
        case searchPhotos(PinLocation)
        case getImage(String, String, String)
        
        var urlString: String {
            switch self {
            case .searchPhotos(let pinLocation):
                return Endpoints.baseUrl + "?method=flickr.photos.search&api_key=\(FlickrClient.apiKey)&lat=\(pinLocation.latitude)&lon=\(pinLocation.longitude)&radius=0.1&sort=date-posted-desc&per_page=100&page=1&format=json&nojsoncallback=1"
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
    
    class func searchPhotos(pinLocation: PinLocation, completion: @escaping ([Photo], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.searchPhotos(pinLocation).url, responseType: SearchPhotosResponse.self) { (response, error) in
            print(response ?? "")
            completion(response!.photos.photo, nil)
        }
    }
    
    class func getImage(id: String, serverId: String, secret: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getImage(id, serverId, secret).url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data), nil)
            }
        }
        task.resume()
    }
}
