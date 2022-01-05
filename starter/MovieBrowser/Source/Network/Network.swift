//
//  Network.swift
//  SampleApp
//
//  Created by Struzinski, Mark - Mark on 9/17/20.
//  Copyright © 2020 Lowe's Home Improvement. All rights reserved.
//

import UIKit

class NetworkController: NSObject, URLSessionDelegate {
    
    static let `default` = NetworkController()
    
    lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }()
    
    func getImage(url: URL, completion: @escaping (UIImage?) -> ()) {
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
    
}

struct Movies {
    
    static let apiKey = "5885c445eab51c7004916b9c0313e2d3"
    
    enum Endpoint {
        case search(query: String)
        case poster(path: String)
        
        var url: URL {
            switch self {
            case .search(let query):
                var url = URLComponents(string: "https://api.themoviedb.org/3/search/movie")!
                url.queryItems = [
                    URLQueryItem(name: "api_key", value: Movies.apiKey),
                    URLQueryItem(name: "query", value: query),
                ]
                return url.url!
            case .poster(let path):
                let urlString = "https://image.tmdb.org/t/p/w600_and_h900_bestv2\(path)"
                return URL(string: urlString)!
            }
        }
    }

    static func getMovies(_ query: String, completion: @escaping ([MovieData]?) -> ()) {
        let url = Movies.Endpoint.search(query: query).url
        
        let task = NetworkController.default.session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            
            var items: [MovieData]? = nil
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                items = searchResult.results
            } catch let error {
                print(error)
            }
            
            completion(items)
        }
        task.resume()
    }
    
    static func getImage(for movie: MovieData, completion: @escaping (UIImage?) -> ()) {
        guard let poster_path = movie.poster_path else { completion(nil); return }
        
        let url = Movies.Endpoint.poster(path: poster_path).url
        
        NetworkController.default.getImage(url: url) { image in
            completion(image)
        }
    }
    
}
