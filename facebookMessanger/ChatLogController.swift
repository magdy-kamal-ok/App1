//
//  ChatLogController.swift
//  facebookMessanger
//
//  Created by magdy on 3/10/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit

class ChatLogController : UICollectionViewController,UICollectionViewDelegateFlowLayout
{
    private var cellId = "cellId"
    var friend:Friend?{
        didSet{
            navigationItem.title = friend?.name
            messages = friend?.messages?.allObjects as?[Message]
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
        }
    }
    var messages:[Message]?
    let messageInputContainerView:UIView={
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField:UITextField={
        let textField = UITextField()
        textField.placeholder = "enter message..."
        return textField
        
    }()
    // we use lazy for wrapping to self in the target function
    lazy var sendButton:UIButton={
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red:0,green:137/255,blue:249/255,alpha:1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for:.touchUpInside)
        return button
        
    }()
    
    var bottomContraint : NSLayoutConstraint?
    func handleSend(){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        
        let message = FriendsController.createMessageWithTex(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context!,isSender:true)
        do{
            try context?.save()
            messages?.append(message)
            let item  = messages!.count-1
            let insertiaonIndexPath = NSIndexPath(item: item, section: 0)
            collectionView?.insertItems(at: [insertiaonIndexPath as IndexPath])
            collectionView?.scrollToItem(at: insertiaonIndexPath as IndexPath, at: .bottom, animated: true)
            inputTextField.text = nil
        
        }
        catch let err{
            print(err)
        }
        
    }
    func simulate(){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let message = FriendsController.createMessageWithTex(text: "here is the incoming message", friend: friend!, minutesAgo: 1, context: context!)
        do{
            try context?.save()
            messages?.append(message)
            
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
            
            if let item  = messages?.index(of: message)
            {
                let receivingIndexPath = NSIndexPath(item: item, section: 0)
                collectionView?.insertItems(at: [receivingIndexPath as IndexPath])
                collectionView?.scrollToItem(at: receivingIndexPath as IndexPath, at: .bottom, animated: true)
                inputTextField.text = nil
            }
        }
        catch let err{
            print(err)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        tabBarController?.tabBar.isHidden = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        self.view.addSubview(messageInputContainerView)
        self.view.addConstraintWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        self.view.addConstraintWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        
        
        // this contraint for hiding and show contraint as bottom V:[v0(40)]|-> removed
         bottomContraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomContraint!)
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide , object: nil)
    }
    func handleKeyboardNotification(notification:NSNotification){
        if let userInfo = notification.userInfo{
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            if isKeyboardShowing{
                 bottomContraint?.constant = -keyboardFrame!.height
            }
            else{
                 bottomContraint?.constant = 0
            }
            
            // this animation to return the input text field to its position
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                self.view.layoutIfNeeded()
            }, completion: {(completed) in
                if isKeyboardShowing{
                let indexPath = NSIndexPath(item: (self.messages?.count)!-1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    private func setupInputComponents()
    {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        messageInputContainerView.addConstraintWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField,sendButton)
        messageInputContainerView.addConstraintWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintWithFormat(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count
        {
            return count
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        
            cell.messageTextView.text = messages?[indexPath.item].text
            if let message = messages?[indexPath.item] , let messageText = message.text , let profileImageName = message.friend?.profileImage
            {
                let size = CGSize(width: 250, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 18)], context: nil)
                cell.profileImageView.image = UIImage(named:profileImageName)
               
                if !message.isSender{
                    cell.messageTextView.frame = CGRect(x: 48+8, y: 0, width: estimatedFrame.width+16, height: estimatedFrame.height+20)
                    cell.textBubbleView.frame = CGRect(x: 48-10, y: -4, width: estimatedFrame.width+16+8+16, height: estimatedFrame.height+20+6)
                    cell.profileImageView.isHidden = false
                 //   cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                    cell.messageTextView.textColor = UIColor.black
                    cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                }
                else{
                    cell.profileImageView.isHidden = true
                    cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width-16-16-8, y: 0, width: estimatedFrame.width+16, height: estimatedFrame.height+20)
                    cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width-16-8-16-16, y: -4, width: estimatedFrame.width+16+8+10, height: estimatedFrame.height+20)
                   // cell.textBubbleView.backgroundColor = UIColor(red:0,green:137/255,blue:249/255,alpha:1)
                    cell.bubbleImageView.tintColor = UIColor(red:0,green:137/255,blue:249/255,alpha:1)
                    cell.messageTextView.textColor = UIColor.white
                    cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                }
            }
      
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageText = messages?[indexPath.item].text
        {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height+20)
        }
        return CGSize(width: view.frame.width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
}

class ChatLogMessageCell:BaseCell{
    
    let messageTextView:UITextView = {
        let textView = UITextView()
        textView.text = "Your friend Message asdsdasdsadsdds ..."
        textView.textColor = UIColor.darkGray
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = UIColor.clear
        return textView
        
    }()
    let textBubbleView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
        
    }()
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    static let grayBubbleImage = UIImage(named: "left")//?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 2, 0,2))
    static let blueBubbleImage = UIImage(named: "right")//?.resizableImage(withCapInsets: UIEdgeInsetsMake(-4, -6, -4,-6))
    let bubbleImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatLogMessageCell.grayBubbleImage//?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 2, 0,2))
        imageView.tintColor = UIColor(white: 0.95, alpha: 1)
        return imageView
    }()
    override func setupViews() {
        super.setupViews()
      //  backgroundColor = UIColor.lightGray
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        addConstraintWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintWithFormat(format: "V:[v0(30)]|", views: profileImageView)
//        addConstraintWithFormat(format: "H:|[v0]|", views: messageTextView)
//        addConstraintWithFormat(format: "V:|[v0]|", views: messageTextView)
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintWithFormat(format: "H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintWithFormat(format: "V:|[v0]|", views: bubbleImageView)
    }

}
