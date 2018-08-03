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
    
    @IBOutlet weak var sourcesPicker: UIPickerView!
    @IBOutlet weak var categoryPickerOutlet: UIPickerView!
    @IBOutlet weak var countryPickerOutlet: UIPickerView!
    
    var categoriesArray = ["general", "business", "entertainment", "health"]
    var countriesArray = ["us", "ae", "it", "ve", "ua", "ru"]
    var sourcesArray = [""]
    var chosenCountry = ""
    var chosenCategory = ""
    var nextPage = 0
    
    var localNews: [NewsModel] = [] {
        didSet {
            nextPage = localNews.count / 20
            if localNews.count != 0 {
                let loadMore = UIButton()
                loadMore.frame.size = CGSize(width: 120, height: 60)
                loadMore.setTitle("LOAD MORE", for: .normal)
                loadMore.titleLabel?.textColor = UIColor.black
                loadMore.backgroundColor = UIColor.lightGray
                loadMore.addTarget(self, action: #selector(loadMoreNews), for: .touchUpInside)
                tableView.tableFooterView = loadMore
                loadMore.center = (tableView.tableFooterView?.center)!
            }
        
        }
    }
    
    lazy var refresher: UIRefreshControl = {
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor(red: 1.00, green: 0.21, blue: 0.55, alpha: 1.00)
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(requestNewData), for: .valueChanged)
        return refreshController
    }()
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        
        let cellNib = UINib(nibName: "\(NewsTableViewCell.self)", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "\(NewsTableViewCell.self)")
        
        categoryPickerOutlet.selectRow(0, inComponent: 0, animated: false)
        countryPickerOutlet.selectRow(0, inComponent: 0, animated: false)
//        requestData()
        requestNews(withCountry: "us", andCategory: "general")
    }
    
    @objc func loadMoreNews() {
        NetworkDataManager.sharedNetworkDataManager.getAllNews(nextPage: nextPage, country: chosenCountry, category: chosenCategory, complition: { news in
            DispatchQueue.main.async {
                for new in news {
                    self.localNews.insert(new, at: self.localNews.endIndex)
                }
                self.tableView.reloadData()
            }
            print("Hooray I recive news in view controller \(news.count)")
        })
    }
    
    @objc func requestNewData() {
        NetworkDataManager.sharedNetworkDataManager.getAllNews(nextPage: nextPage, country: chosenCountry, category: chosenCategory, complition: { news in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {return}
                for new in news {
                    if weakSelf.localNews.contains(where: { $0.url != new.url }) {
                        weakSelf.localNews.insert(new, at: news.startIndex)
                    }
                }
                //                self.localNews += newNews
                //                self.localNews.append(contentsOf: newNews)
                //                newNews.append(contentsOf: self.localNews)
                weakSelf.tableView.reloadData()
                //                newNews = []
            }
            print("Hooray I recive news in view controller \(news.count)")
        })
        
        let deadline = DispatchTime.now() + .milliseconds(800)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func requestData() {
        NetworkDataManager.sharedNetworkDataManager.getAllNews(nextPage: nextPage, country: chosenCountry, category: chosenCategory, complition: {news in
            DispatchQueue.main.async {
                self.localNews = []
                self.localNews = news
                self.tableView.reloadData()
            }
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
        cell.selectionStyle = .none
        
        let currentNew = localNews[indexPath.row]
        cell.titleLabel.text = currentNew.title
        cell.descripton.text = currentNew.description
        cell.authorLabel.text = currentNew.author
        cell.nameOrtlet.text = currentNew.name
        cell.imageOutlet.image = #imageLiteral(resourceName: "defaultImage")
        cell.imageOutlet.downloadedFrom(link: currentNew.imageURLString)
        
        
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
    
    func requestNews(withCountry country: String, andCategory category: String, source: String? = nil) {
        NetworkDataManager().getAllNews(nextPage: nil, country: country, category: category) { news in
            self.localNews.removeAll()
            DispatchQueue.main.async {
                for new in news {
                    self.localNews.append(new)
                }
                self.tableView.reloadData()
            }
        }
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

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count > 0 {
            searchingPhrase = text
            requestData()
            searchBar.resignFirstResponder()
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case categoryPickerOutlet:
            return categoriesArray.count
        case countryPickerOutlet:
            return countriesArray.count
        case sourcesPicker:
            return sourcesArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case categoryPickerOutlet:
            return categoriesArray[row]
        case countryPickerOutlet:
            return countriesArray[row]
        case sourcesPicker:
            return sourcesArray[row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case categoryPickerOutlet:
             chosenCategory = categoriesArray[row]
        case countryPickerOutlet:
             chosenCountry = countriesArray[row]
        default:
            break
        }
        requestNews(withCountry: chosenCountry, andCategory: chosenCategory)
    }
    
}


