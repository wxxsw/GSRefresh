//
//  MenuViewController.swift
//  Example
//
//  Created by Gesen on 2017/11/2.
//  Copyright © 2017年 Gesen <i@gesen.me>. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tableVC = segue.destination as? TableViewController else {
            return
        }
        
        switch segue.identifier! {
        case "basicDefault": tableVC.page = .basic(.default)
        default: break
        }
    }

}
