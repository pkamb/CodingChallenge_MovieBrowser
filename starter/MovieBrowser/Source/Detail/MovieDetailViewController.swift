//
//  MovieDetailViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/26/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var movie: MovieData!
    var posterImage: UIImage?
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!

    override func viewDidLoad() {
        titleLabel.text = movie.title
        dateLabel.text = movie.releaseDate
        overviewLabel.text = movie.overview
        
        if let posterImage = posterImage {
            posterImageView.image = posterImage
        } else {
            posterImageView.image = UIImage(named: "placeholder")
            Movies.getImage(for: movie) { image in
                DispatchQueue.main.async {
                    self.posterImageView.image = image
                }
            }
        }
    }
    
}
