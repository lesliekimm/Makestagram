//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Leslie Kim on 11/2/15.
//  Copyright © 2015 Make School. All rights reserved.
//

import UIKit

class PostSectionHeaderView: UITableViewCell {

    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    var post: Post? {
        didSet {
            if let post = post {
                usernameLabel.text = post.user?.username
            }
        }
    }
}
