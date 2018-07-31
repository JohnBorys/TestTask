//
//  ViewController.swift
//  TestTask
//
//  Created by Іван on 7/26/18.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit
import SafariServices


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {
    var localNews: [NewsModel] = []
    
    lazy var refresher: UIRefreshControl = {
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor(red: 1.00, green: 0.21, blue: 0.55, alpha: 1.00)
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshController
    }()
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        
        let cellNib = UINib(nibName: "\(NewsTableViewCell.self)", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "\(NewsTableViewCell.self)")
        requestData()
    }
    
    @objc func requestData() {
        NetworkDataManager.sharedNetworkDataManager.getAllNews(complition: {news in
            DispatchQueue.main.async {
//                self.localNews = news
                self.localNews.append(contentsOf: news)
                self.tableView.reloadData()
                
            }
             print("Hooray I recive news in view controller \(news.count)")
        })
        
        let deadline = DispatchTime.now() + .milliseconds(800)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NewsTableViewCell.self)") as! NewsTableViewCell
        let currentCell = localNews[indexPath.row]
        cell.titleLabel.text = currentCell.title
        cell.descripton.text = currentCell.description
        cell.authorLabel.text = currentCell.author
        cell.sourceOrtlet.text = currentCell.name
        cell.imageOutlet.downloadedFrom(link: currentCell.imageURLString)
        
        return cell
    }
    
    func showWebsite(url: String) {
        let URL = NSURL(string: url)!
        let webVC = SFSafariViewController(url: URL as URL)
        webVC.delegate = self
        self.present(webVC, animated: true, completion: nil)
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentNew = localNews[indexPath.row]
        let url = currentNew.url
        self.showWebsite(url: url)
    }
    
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

//extension UIImageView {
//
//    func downloadedFrom(link:String) {
//        guard let url = URL(string: link) else { return }
//        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
//            guard let data = data , error == nil, let image = UIImage(data: data) else { return }
//            DispatchQueue.main.async { () -> Void in
//                self.image = image
//            }
//        }).resume()
//    }
//}




