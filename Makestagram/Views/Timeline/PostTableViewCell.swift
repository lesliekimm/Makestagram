//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Leslie Kim on 10/30/15.
//  Copyright © 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    var post: Post? {
        didSet {
            // use disposable variables to destroy old bindings
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            if let post = post {
                // bind to diff props of post
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    // use optinal binding to ensure value is not nil
                    if let value = value {
                        // dispaly list of UNs of all users that have liked the post
                        self.likesLabel.text = self.stringFromUserList(value)
                        // set state of like button on whether current use has liked
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        // hide small heart icon if no one has liked
                        self.likesIconImageView.hidden = (value.count == 0)
                    }
                    else {
                        // if we havne't received a value, set all UI elements to default
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
 
    // generates a comma separated list of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        // use mapt o replace objects in collection w/ other objects
        let usernameList = userList.map { user in user.username! }
        // create one joint string
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        
        return commaSeparatedUserList
    }
}
