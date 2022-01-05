//
//  Model.swift
//  MovieBrowser
//
//  Created by Peter Kamb on 12/20/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation
import UIKit

struct SearchResult: Decodable {
    let total_results: Int
    let results: [MovieData]
}

struct MovieData: Decodable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String?
    let release_date: String?
    let popularity: Double?
    let vote_average: Double?
    
    var rating: String? {
        guard let vote_average = vote_average, vote_average != 0.0 else { return nil }
        return String(format: "%.1f", vote_average)
    }
    
    var releaseYear: String? {
        guard let release_date = release_date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from:release_date) else { return nil }
        
        let output = DateFormatter()
        output.dateFormat = "yyyy"
        let outputString = output.string(from: date)
        return outputString
    }
    
    var releaseDate: String? {
        guard let release_date = release_date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from:release_date) else { return nil }
        
        let output = DateFormatter()
        output.dateFormat = "MMMM dd, yyyy"
        let outputString = output.string(from: date)
        return outputString
    }
    
    var yearDisplayString: NSAttributedString? {
        guard let releaseYear = releaseYear else { return nil}
        return NSAttributedString.with(image: UIImage(systemName: "calendar")!, text: releaseYear)
    }
    
    var ratingDisplayString: NSAttributedString? {
        guard let rating = rating else { return nil }
        return NSAttributedString.with(image: UIImage(systemName: "star.bubble")!, text: rating)
    }

    
}

extension NSAttributedString {
    
    static func with(image: UIImage, text: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(attachment: attachment))
        if text.count > 0 {
            string.append(NSAttributedString(string: " "))
            string.append(NSAttributedString(string: text))
        }
        return string
    }
    
}
