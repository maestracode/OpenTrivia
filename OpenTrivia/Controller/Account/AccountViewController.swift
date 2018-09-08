//
//  AccountViewController.swift
//  OpenTrivia
//
//  Created by omaestra on 07/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import UIKit
import Kingfisher

class AccountViewController: UIViewController {

    @IBOutlet weak var usernameTitle: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.transparentNavigationBar()
        navigationController?.navigationBar.barStyle = .black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
