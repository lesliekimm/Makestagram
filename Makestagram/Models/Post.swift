//
//  Post.swift
//  Makestagram
//
//  Created by Leslie Kim on 10/30/15.
//  Copyright © 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

// custom Parse class (must inherit from PFObject & implement PFSubclassing protocol
class Post: PFObject, PFSubclassing {
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    var likes: Observable<[PFUser]?> = Observable(nil)
    
    // defined each prop that you want to access on this Parse class
    // this allows you to change the code that accesses props through strings
    // user & image file
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    // by implemented parselClassName, you create connection between the Parse class and your swift class
    static func parseClassName() -> String {
        return "Post"
    }
    
    // init & initialize are boilerplate code - copy into any custom Pase class
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadPost() {
        if let image = image.value {
                photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            // grab image that is selected, convert to PFFile and upload
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let imageFile = PFFile(data: imageData!)
            
            imageFile.saveInBackgroundWithBlock(nil)
            // saveInBackgroundWithBlock allows us to pass it a callback in the form of a colsure which is
            // execute once the task running on the bg thread is completed (i.e. when photo upload is complete)
            // very useful but right now we don't need to be informed when upload is complete so we pass nil
            
            // assigned signed in user to the Post object
            user = PFUser.currentUser()
            // assign imigeFile to self (which is the Post being uploaded) and save to store to Post
            self.imageFile = imageFile
            saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    func downloadImage() {
        // if image is not downloaded yet, get it
        // check if image.value already has a stored value (do this to avoid DL images multiple times)
        if (image.value == nil) {
            // start DL and use getDataInBackroundWithBlock to avoid blocking the main thread
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // once DL completes, update post.image
                    self.image.value = image
                }
            }
        }
    }
    
    func fetchLikes() {
        // check whether likes.value already has stored a value or is nil
        if (likes.value != nil) {
            return
        }
        
        // we fetch the likes for the current Post using the method of ParseHelper
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            // return an array that contains only objects from original array that meet requiremented stated in closure
            // we are removing all likes that belong to users that no longer exist in our Makestagram app
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // called for each element in the array & returns a new array as a result
            // map replaces objects (isntead of removing like filter)
            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
}