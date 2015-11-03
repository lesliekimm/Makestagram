//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Leslie Kim on 10/30/15.
//  Copyright © 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController, TimelineComponentTarget {
    var photoTakingHelper: PhotoTakingHelper?
    @IBOutlet weak var tableView: UITableView!
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!     // the type of object you display, the class that wll be target of TimelineComponent

    override func viewDidLoad() {
        super.viewDidLoad()

        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        timelineComponent.loadInitialIfRequired()
        self.tabBarController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!,  callback: { (image: UIImage?) in
            let post = Post()
            post.image.value = image!
            post.uploadPost()
            })
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // call timelineRequestForCurrentUser method
        ParseHelper.timelineRequestForCurrentUser(range) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            // in callback of query, check whther or not we have received a result
            let posts = result as? [Post] ?? []
            // pass posts that have been loaded back to the TimelineComponenet by calling the completionBlock
            completionBlock(posts)
        }
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
    
    // very similar to displaying posts
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension TimelineViewController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        }
        else {
            return true
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return timelineComponent.content.count
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // cast cell to our custom class PostTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.section]
        // directly before a post is displayed, trigger image DL
        post.downloadImage()
        post.fetchLikes()
        // instead of changing image that is displayed in cell form w/in TVC, assign post to be displayed to post prop
        cell.post = post
        
        return cell
    }
}