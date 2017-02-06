//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Apple on 2017/1/29.
//  Copyright © 2017年 Xinmeng Li. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

@IBOutlet weak var tableView: UITableView!
@IBOutlet weak var searchBar: UISearchBar!
    
var movies: [NSDictionary]?
var filteredDic: [NSDictionary]?
override func viewDidLoad() {
super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
    let myRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    let task: URLSessionDataTask = session.dataTask(with: myRequest) { (data: Data?, response: URLResponse?, error: Error?) in
        if let data = data {
            if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dataDictionary)
                self.movies = dataDictionary["results"] as? [NSDictionary]
                self.filteredDic = self.movies
                self.tableView.reloadData()
            }
        }
    };
    self.loadDataFromNetwork()
    // Initialize a UIRefreshControl
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for:UIControlEvents.valueChanged)
    self.tableView.insertSubview(refreshControl, at: 0)
    task.resume()

}
    
    
    
// Makes a network request to get updated data
// Updates the tableView with the new data
// Hides the RefreshControlsel
func refreshControlAction(_ refreshControl: UIRefreshControl) {

    // ... Create the URLRequest `myRequest` ...
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
    let myRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    // Configure session so that completion handler is executed on main UI thread
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    let task: URLSessionDataTask = session.dataTask(with: myRequest) { (data: Data?, response: URLResponse?, error: Error?) in
        // ... Use the new data to update the data source ...
        if let data = data {
            if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dataDictionary)
                
                self.movies = dataDictionary["results"] as? [NSDictionary]
                self.tableView.reloadData()
            }
        }
    };
    // Reload the tableView now that there is new data
    self.tableView.reloadData()
    // Tell the refreshControl to stop spinning
    refreshControl.endRefreshing()
    task.resume()
}
    
 
    
func loadDataFromNetwork() {

    // ... Create the NSURLRequest (myRequest) ...
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
    let myRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    // Configure session so that completion handler is executed on main UI thread
    let session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate:nil,
        delegateQueue:OperationQueue.main
    )
    // Display HUD right before the request is made
    MBProgressHUD.showAdded(to: self.view, animated: true)
    let task : URLSessionDataTask = session.dataTask(with: myRequest,
    completionHandler: { (data, response, error) in
    // Hide HUD once the network request comes back (must be done on main UI thread)
    MBProgressHUD.hide(for: self.view, animated: true)
    });
    task.resume()
}
    
    
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.filteredDic = self.movies?.filter({ (movies) -> Bool in
        return (movies["title"] as! String).range(of: searchText, options:.caseInsensitive, range: nil, locale: nil) != nil
    })
    /*DispatchQueue.main.async {
        self.collectionView.reloadData()
    }*/
    self.tableView.reloadData()
}
    
func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.searchBar.showsCancelButton = true
}
    
func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.text = ""
    searchBar.resignFirstResponder()
    viewDidLoad()

}
    
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}


func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    if let filteredDic = filteredDic{
        return filteredDic.count
    }
    else{
        return 0
    }
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    let movie = filteredDic![indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String
    let posterPath = movie["poster_path"] as! String
    let baseUrl = "https://image.tmdb.org/t/p/w500"
    let imageUrl = baseUrl+posterPath
    let imageRequest = NSURLRequest(url: NSURL(string: imageUrl)! as URL)
    cell.titleLabel.text = title
    cell.overviewLabel.text = overview
    cell.posterView.setImageWith(
        imageRequest as URLRequest,
        placeholderImage: nil,
        success: { (imageRequest, imageResponse, image) -> Void in
            // imageResponse will be nil if the image is cached
            if imageResponse != nil {
                print("Image was NOT cached, fade in image")
                cell.posterView.alpha = 0.0
                cell.posterView.image = image
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    cell.posterView.alpha = 1.0
                })
            } else {
                print("Image was cached so just update the image")
                cell.posterView.image = image
            }
    },
        failure: { (imageRequest, imageResponse, error) -> Void in
            // do something for the failure condition
            print("Failed to load image")
    })
    print("row\(indexPath.row)")
    return cell
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
