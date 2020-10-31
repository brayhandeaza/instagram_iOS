//
//  FeedViewController.swift
//  Instagram_iOS
//
//  Created by Brayhan De Aza on 10/22/20.
//

import UIKit
import AlamofireImage
import Parse
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let commentsBar = MessageInputBar()
    var showCommentBar = false
   
    
    var posts = [PFObject]()
    var currentPost: PFObject!
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsBar.inputTextView.placeholder = "Add a comment"
        commentsBar.sendButton.title = "Post"
        commentsBar.delegate = self
        

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardWillBeHidden(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyBoardWillBeHidden(note: Notification)  {
        commentsBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentsBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author","comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground {(post, erroe) in
            if post != nil {
                self.posts = post!
                self.tableView.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = currentPost
        comment["author"] = PFUser.current()!
        
        currentPost.add(comment, forKey: "comments")
        currentPost.saveInBackground { (succes, error) in
            if succes {
                print("Comment saved")
            } else {
                print("Error saving comment: \(String(describing: error))")
            }
        }
        
        tableView.reloadData()
        
        commentsBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentsBar.inputTextView.resignFirstResponder()
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return  comments.count + 2
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.caption.text = post["caption"] as? String
            cell.username.text = user.username

            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.postImage.af_setImage(withURL: url)
            
            return cell
            
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell") as! CommentsCell
            
            let comment = comments[indexPath.row - 1]
            cell.comments.text = comment["text"] as? String

            let user = comment["author"] as? PFUser
            cell.username.text = user?.username
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentsCell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        print(indexPath.row == comments.count + 1)
        
//        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentsBar.inputTextView.becomeFirstResponder()
            currentPost = post
            print(post)
//        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
}
