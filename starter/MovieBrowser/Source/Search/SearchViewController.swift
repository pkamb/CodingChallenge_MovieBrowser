//
//  SearchViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/19/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit





/*
 *
 * Movie Search iOS Sample Project
 *
 * By Peter Kamb, December 2021
 * 
 * https://github.com/pkamb
 *
 */





class SearchViewController: UITableViewController {
    
    var posterCache = NSCache<NSString, UIImage>()
    
    let exampleMovieSearches = [ "shape", "king", "queen", "samurai", "lake", "mountain", "river", "sea", "water", "grass", "city"]
    var previousSearch: String?
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        var snapshot = datasource.snapshot()
        snapshot.appendSections([0])
        datasource.apply(snapshot, animatingDifferences: false)
        
        searchBar.text = exampleMovieSearches.randomElement()
        performMovieSearch()
        searchBar.becomeFirstResponder()
    }
    
    lazy var datasource: UITableViewDiffableDataSource<Int, MovieData> = {
        let datasource = UITableViewDiffableDataSource<Int, MovieData>(tableView: tableView, cellProvider: { (tableView, indexPath, model) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MovieCell.self), for: indexPath) as! MovieCell
            cell.titleLabel.text = model.title
            cell.dateLabel.attributedText = model.yearDisplayString
            cell.ratingLabel.attributedText = model.ratingDisplayString
            
            if let posterPath = model.poster_path, let cachedPoster = self.posterCache.object(forKey: posterPath as NSString) {
                cell.posterImageView.image = cachedPoster
            } else {
                cell.posterImageView.image = UIImage(named: "placeholder")
                self.cachePoster(for: model)
            }
            
            return cell
        })
        
        datasource.defaultRowAnimation = .fade
        return datasource
    }()
    
    let movieDetailSegueID = "MovieDetail"
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: movieDetailSegueID, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == movieDetailSegueID,
           let movieDetail = segue.destination as? MovieDetailViewController,
           let indexPath = sender as? IndexPath,
           let movie = datasource.itemIdentifier(for: indexPath)
        {
            movieDetail.movie = movie
            if let posterPath = movie.poster_path, let cachedPoster = self.posterCache.object(forKey: posterPath as NSString) {
                movieDetail.posterImage = cachedPoster
            }
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: Any?) {
        let alert = UIAlertController(title: "iOS Sample Project",
                                      message: "\nCreated by Peter Kamb\n December 2021", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "👍", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    @IBAction func randomSearch(_ sender: UIBarButtonItem) {
        searchBar.text = exampleMovieSearches.filter({ $0 != previousSearch }).randomElement()
        performMovieSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performMovieSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: search as you type
    }
    
    func performMovieSearch() {
        let searchTerm = searchBar.text ?? ""
        previousSearch = searchTerm
        Movies.getMovies(searchTerm) { movieData in
            DispatchQueue.main.async {
                var snapshot = self.datasource.snapshot()
                snapshot.deleteAllItems()
                snapshot.appendSections([0])
                snapshot.appendItems(movieData ?? [], toSection: 0)
                self.datasource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    func cachePoster(for movie: MovieData) {
        guard let posterPath = movie.poster_path else { return }
        
        Movies.getImage(for: movie) { image in
            if let image = image {
                self.posterCache.setObject(image, forKey: posterPath as NSString)
            }
            
            DispatchQueue.main.async {
                var snapshot = self.datasource.snapshot()
                if snapshot.sectionIdentifier(containingItem: movie) != nil {
                    snapshot.reloadItems([movie])
                }
                self.datasource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
}

class MovieCell: UITableViewCell {
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
}
