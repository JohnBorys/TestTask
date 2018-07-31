//
//  ViewController.swift
//  TestTask
//
//  Created by Іван on 7/26/18.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var localNews: [NewsModel] = []
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "\(NewsTableViewCell.self)", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "\(NewsTableViewCell.self)")
        
        NetworkDataManager.sharedNetworkDataManager.getAllNews(complition: {news in
            DispatchQueue.main.async {
                self.localNews = news
                self.tableView.reloadData()
            }
            print("Hooray I recive news in view controller \(news.count)")
        })
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
        cell.sourceOrtlet.text = currentCell.source
        cell.imageOutlet.downloadedFrom(link: currentCell.imageURLString)
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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




