//
//  ViewController.swift
//  StoreSearch
//
//  Created by пользователь on 21.02.17.
//  Copyright © 2017 Eugene Uskov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    struct TableViewCellIdentifiers {
     
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let search = Search()
    
    var landscapeViewController: LandscapeViewController?
    
    
    
    //-----------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------
   
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        performSearch()
    }
    
    
    
   
    
    
    func showNetworkError() {
        
        let alert = UIAlertController(
            title: "Whoops...",
            message:
            "There was an error reading from the iTunes Store. Please try again.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func kindForDisplay(_ kind: String) -> String {
        
        switch kind {
        
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        
        default: return kind
        }
    }
    
    
    
    //-----------------------------------------------------------------------------------------------
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetail" {
    
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = search.searchResults[indexPath.row]
            
            detailViewController.searchResult = searchResult
        }
    }
    
    //------------------------------------------------------------------------------------------
    // used to show another view controller in landscape
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        
        case .compact:
            showLandscape(with: coordinator)
        
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard landscapeViewController == nil else { return }

        landscapeViewController = storyboard!.instantiateViewController(
            withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { _ in
            
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                
                if self.presentedViewController != nil {
                
                    self.dismiss(animated: true, completion: nil)
                }
                
            }, completion: { _ in
            
                controller.didMove(toParentViewController: self)
            })
        }
    }
    
    func hideLandscape(with coordinator:UIViewControllerTransitionCoordinator)
    {
        if let controller = landscapeViewController {
         
            controller.willMove(toParentViewController: nil)
     
            coordinator.animate(alongsideTransition: { _ in
            
                controller.view.alpha = 0
            
            }, completion: { _ in
            
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                
                self.landscapeViewController = nil
            })
        }
    }
    
}




//-----------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------


extension SearchViewController: UISearchBarDelegate {
    
   
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
     
        performSearch()
    }
    
    
    
    func performSearch() {
        
        search.performSearch(for: searchBar.text!,
                             category: segmentedControl.selectedSegmentIndex,
                             completion: { success in
                              
                                if !success {
                                    self.showNetworkError()
                                }
                                
                                self.tableView.reloadData()
        })
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

}
//-----------------------------------------------------------------------------------------------




extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if search.isLoading {
            return 1  // Loading...
        } else if !search.hasSearched {
            return 0  // Not searched yet
        } else if search.searchResults.count == 0 {
            return 1  // Nothing Found
        } else {
            return search.searchResults.count
        }
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier:TableViewCellIdentifiers.loadingCell, for: indexPath)
           
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
        
            return cell
        
        } else if search.searchResults.count == 0 {
            
            return tableView.dequeueReusableCell(
                withIdentifier: TableViewCellIdentifiers.nothingFoundCell,
                for: indexPath)
        
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            
            let searchResult = search.searchResults[indexPath.row]
            
            cell.configure(for: searchResult)
            
            return cell
        }
        
    }
}


//-----------------------------------------------------------------------------------------------



extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if search.searchResults.count == 0 || search.isLoading {
        
            return nil
       
        } else {
        
            return indexPath
        }
    }

}
