//
//  ViewController.swift
//  QuickSearch
//
//  Created by 何子龙 on 18/01/2017.
//  Copyright © 2017 何子龙. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import SafariServices

class ViewController: UIViewController {

    // MARK: Variables
    
    var keyboardOnScreen = false
    var getDaily = false
    
    // MARK: Properties
    
    var Result = [result]()
    
    // MARK: Outlets
    
    let searchBar = UISearchBar()
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customize tableview features
        resultTableView.separatorStyle = .none
        resultTableView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        
        
        // check if 3d touch avaiable
        if (traitCollection.forceTouchCapability == .available ){
            registerForPreviewing(with: self, sourceView: self.resultTableView)
        }
        
        // if this VC is activated by shortcut item "正在上映" dont create search bar.
        if getDaily {
            self.navigationItem.title = "正在上映"
            getDailyMovie()
        } else {
            createSearchBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Configure UI
    
    func createSearchBar() {
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "搜索你感兴趣的电影、影人"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }
    
    private func setUIEnabled(_ enabled: Bool) {
        searchBar.isUserInteractionEnabled = enabled
        
        if enabled {
            searchBar.alpha = 1.0
        } else {
            searchBar.alpha = 0.5
        }
    }

    // MARK: Network Method
    
    func getDailyMovie() {
        if !(Result.isEmpty) {
            Result.removeAll()
            resultTableView.reloadData()
        }
        
        let params = [
            Constants.DoubanParameterKeys.Location: "广州"
        ]
        getDataFromDouban(params as [String : AnyObject])
    }
    
    func getDataFromDouban(_ params: [String:AnyObject]) {
        
        let url = getURLfromParams(params)
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
            }
            
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            let json = JSON(data: data)
            for (_, subJson):(String, JSON) in json["subjects"] {
                
                var castsWithFormat = "主演："
                var ratingWithFormat = "评分："
                var date = ""
                var titleWithFormat = ""
                
                let castArray = subJson["casts"]
                for (_, subCastJson):(String, JSON) in castArray {
                    if let castName = subCastJson["name"].string {
                        castsWithFormat += "\(castName) "
                    }
                }
                
                let title: String = subJson["title"].stringValue
                let url: String = subJson["alt"].stringValue
                let posterUrl: String = subJson["images"]["small"].stringValue
                let rating: Float = subJson["rating"]["average"].floatValue
                ratingWithFormat += String(rating)
                
                if let dateString = subJson["year"].string {
                    date = dateString
                    if !dateString.isEmpty {
                        titleWithFormat = "\(title)(\(dateString))"
                    } else {
                        titleWithFormat = title
                    }
                } else {
                    displayError("Could not find key 'year'.")
                    return
                }
                
                self.Result.append(result(titleWithFormat, ratingWithFormat, date, castsWithFormat, url, posterUrl))
            }

            performUIUpdatesOnMain {
                self.setUIEnabled(true)
                self.resultTableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    private func getURLfromParams(_ params: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Douban.APIScheme
        components.host = Constants.Douban.APIHost
        components.path = getDaily ? Constants.Douban.NowAPIPath : Constants.Douban.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

}

// MARKL - ViewController: UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if !(Result.isEmpty) {
            Result.removeAll()
            resultTableView.reloadData()
        }
        
        let searchContent = searchBar.text
        let params = [
            Constants.DoubanParameterKeys.Query: searchContent
        ]
        getDataFromDouban(params as [String : AnyObject])
    }
}

// MARK: - ViewController: UITextFieldDelegate

//extension ViewController: UITextFieldDelegate {
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        search(self)
//        return true
//    }
//    
//    func resignIfFirstResponder(_ textField: UITextField) {
//        if textField.isFirstResponder {
//            textField.resignFirstResponder()
//        }
//    }
//    
//    func keyboardWillShow(_ notification: Notification) {
//        keyboardOnScreen = true
//    }
//    
//    func keyboardWillHide(_ notification: Notification) {
//        keyboardOnScreen = false
//    }
//    
//    func keyboardDidShow(_ notification: Notification) {
//        gestureRecognizer.cancelsTouchesInView = true
//    }
//    
//    func keyboardDidHide(_ notification: Notification) {
//        gestureRecognizer.cancelsTouchesInView = false
//    }
//}

// MARK: - ViewController: UITableViewDataSource, UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.Result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultTableViewCell
        let item = self.Result[indexPath.row]
        
        cell.item = item
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safariVC = SFSafariViewController(url: URL(string: Result[indexPath.row].url)!)
        safariVC.view.tintColor = UIColor(red: 248/255.0, green: 47/255.0, blue: 38/255.0, alpha: 1.0)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ViewController: UIViewControllerPreviewingDelegate

extension ViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = resultTableView.indexPathForRow(at: location),
            let cell = resultTableView.cellForRow(at: indexPath) else { return nil }
        
        let destinationVC = SFSafariViewController(url: URL(string: Result[indexPath.row].url)!)
        destinationVC.view.tintColor = UIColor(red: 248/255.0, green: 47/255.0, blue: 38/255.0, alpha: 1.0)
        destinationVC.delegate = self

        destinationVC.preferredContentSize = CGSize(width: 0.0, height: 600)
        previewingContext.sourceRect = cell.frame
        return destinationVC
        
    }
}

// MARK: - ViewController (Notifications)

private extension ViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - ViewController: SFSafariViewControllerDelegate

extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}






