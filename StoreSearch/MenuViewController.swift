//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by пользователь on 12.04.17.
//  Copyright © 2017 Eugene Uskov. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
        
            delegate?.menuViewControllerSendSupportEmail(self)
        }
    }
   
}

protocol MenuViewControllerDelegate: class {
    
    func menuViewControllerSendSupportEmail(_ controller: MenuViewController)
}
