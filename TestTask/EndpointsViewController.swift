//
//  EndpointsViewController.swift
//  TestTask
//
//  Created by Іван on 8/2/18.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit

class EndpointsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Endpoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "endpointsCell", for: indexPath)
        cell.textLabel?.text = Endpoints(rawValue: indexPath.row)?.getName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let segueStorybord = UIStoryboard(name: "Main", bundle: nil)
//                if let viewController = segueStorybord.instantiateViewController(withIdentifier: "viewController") as? ViewController {
//                    let currentEndpoint = Endpoints(rawValue: indexPath.row)
//                    viewController.currentEndpoints = currentEndpoint
//                    self.navigationController?.pushViewController(viewController, animated: true)
//                }
    }

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedRow = indexPath.row
            let vc = segue.destination as! ViewController
            vc.currentEndpoints = Endpoints(rawValue: selectedRow)
        }
    }
 

}
