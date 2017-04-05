//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by пользователь on 17.03.17.
//  Copyright © 2017 Eugene Uskov. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var search: Search!
    private var firstTime = true
    private var downloadTasks = [URLSessionDownloadTask]()
    
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
     
        UIView.animate(withDuration: 0.3, delay: 0,
                       options: [.curveEaseInOut], animations: {
                        
                        self.scrollView.contentOffset = CGPoint(
                            x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                            y: 0) },
                       completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        pageControl.numberOfPages = 0

        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime {
         
            firstTime = false
            tileButtons(search.searchResults)
        }
    }
    
    private func tileButtons(_ searchResults: [SearchResult]) {
     
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        switch scrollViewWidth {
        
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        
        default:
            break
        }
        
        var row = 0
        var column = 0
        var x = marginX
        
        for (index, searchResult) in searchResults.enumerated() {
        
            // 1
            let button = UIButton(type: .custom)
            
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
        
            // 2
            button.frame = CGRect(
                // 3
                x: x + paddingHorz,
                y: marginY + CGFloat(row) * itemHeight + paddingVert,
                width: buttonWidth, height: buttonHeight)
            
            downloadImage(for: searchResult, andPlaceOn: button)
            
            scrollView.addSubview(button)
            // 4
            row += 1
            
            if row == rowsPerPage {
                
                row = 0; x += itemWidth; column += 1
            
                if column == columnsPerPage {
                
                    column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages)*scrollViewWidth,
            height: scrollView.bounds.size.height)
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
        print("Number of pages: \(numPages)")
    }
    
    
    private func downloadImage(for searchResult: SearchResult,
                               andPlaceOn button: UIButton) {
        
        if let url = URL(string: searchResult.artworkSmallURL) {
            
            let downloadTask = URLSession.shared.downloadTask(with: url) {
                
                [weak button] url, response, error in
                
                if error == nil, let url = url, let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            
            downloadTasks.append(downloadTask)
            downloadTask.resume()
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
     
        print("deinit \(self)")
        
        for task in downloadTasks {
            task.cancel()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LandscapeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
        
        pageControl.currentPage = currentPage
    }
}
