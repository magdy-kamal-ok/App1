//
//  ViewController.swift
//  facebookMessanger
//
//  Created by magdy on 3/8/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import CoreData
class FriendsController: UICollectionViewController,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate {
    private let cellId = "cellId"
    //var messages:[Message]?
    
    lazy var fetchedResultsController:NSFetchedResultsController={() -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"lastMessage.date",ascending:false)]
        // this predicate is used for empty row or empty elements
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    var blockOperations = [BlockOperation]()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert
        {
            // this for is you simulate multi messages
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
            
            //collectionView?.scrollToItem(at: newIndexPath!, at: .bottom, animated: true)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView?.performBatchUpdates({
            for operation in self.blockOperations
            {
                operation.start()
            }
        }, completion: {(completed) in
            let lastItem = (self.fetchedResultsController.sections?[0].numberOfObjects)!-1
            let indexPath = NSIndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.title =
        self.navigationController?.navigationBar.topItem?.title = "Recent"
        collectionView?.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        setupData()
        
        do{
            try fetchedResultsController.performFetch()
        }
        catch let err {
            print(err)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .plain, target: self, action: #selector(addMark))
    }
    func addMark()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext

        let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context!)as! Friend
        //let mark = Friend(context: context)
        mark.name = "mark FaceBook"
        mark.profileImage = "myimage"
        
        FriendsController.createMessageWithTex(text: "helllo thereeeeeee asdsasadas fr", friend: mark, minutesAgo: 0, context: context!)
        

        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let count = fetchedResultsController.sections?[section].numberOfObjects
        {
            return count;
        }

//        if let count = messages?.count
//        {
//        return count;
//        }
        return 0;
    }

     override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
       
        let friend = fetchedResultsController.object(at: indexPath) as! Friend
        
        cell.message = friend.lastMessage
        

        
//        if let message = messages?[indexPath.item]
//        {
//            cell.message = message
//        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        

        return CGSize(width: view.frame.width, height: 100)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout:layout)
        
        let friend = fetchedResultsController.object(at: indexPath) as! Friend

        
        controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
        //(UIApplication.shared.windows[0].rootViewController as! UINavigationController).pushViewController(controller, animated: true)
    }

}

class MessageCell:BaseCell
{
    
    override var isHighlighted: Bool
    {
        didSet
        {
            backgroundColor = isHighlighted ? UIColor(red:0,green:134/255,blue:249/255,alpha:1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    // this message property
    
    var message:Message? {
        didSet{
            nameLabel.text = message?.friend?.name
            if let profileImageName = message?.friend?.profileImage{
                profileImageView.image = UIImage(named:profileImageName)
                hasReadImageView.image = UIImage(named:profileImageName)
            }
            messageLabel.text = message?.text
            if let date = message?.date
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:m a"
                // this to check if date has elapsed more than day
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                let secondInDays:TimeInterval = 60*60*24
                
                
                if elapsedTimeInSeconds > 7*secondInDays{
                    dateFormatter.dateFormat = "MMM/dd/yy"
                }

                else if elapsedTimeInSeconds > secondInDays{
                    dateFormatter.dateFormat = "EEE"
                }
                
                timeLabel.text = dateFormatter.string(from: date as Date)
            }
        }
    }
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let dividerLineView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    let nameLabel:UILabel = {
        let label = UILabel()
        label.text = "Friend Name"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
        
    }()
    let messageLabel:UILabel = {
        let label = UILabel()
        label.text = "Your friend Message asdsdasdsadsdds ..."
        label.textColor = UIColor.darkGray
         label.font = UIFont.systemFont(ofSize: 14)
        return label
        
    }()
    let timeLabel:UILabel = {
        let label = UILabel()
        label.text = "12:05 pm"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
        
    }()
    
    let hasReadImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    override func setupViews()
    {
       

        addSubview(profileImageView)

        addSubview(dividerLineView)
        
        profileImageView.image = UIImage(named: "myimage")
        hasReadImageView.image = UIImage(named: "myimage")
        setupContainerView()
        // this make the contraint to work
//        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
//        
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        // horizontal from right edge to left edge H:|[v0]|
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[v0(68)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":profileImageView]))
//        // vertical from top edge to bottom edge V:|[v0]|
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[v0(68)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":profileImageView]))
//        
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-82-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":dividerLineView]))
//        // vertical from top edge to bottom edge V:|[v0]|
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(1)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":dividerLineView]))
        
        addConstraintWithFormat(format: "V:[v0(68)]", views: profileImageView)
        addConstraintWithFormat(format: "H:|-12-[v0(68)]", views: profileImageView)
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraintWithFormat(format: "H:|-82-[v0]|", views: dividerLineView)
        addConstraintWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
    }
    private func setupContainerView()
    {
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraintWithFormat(format: "H:|-90-[v0]|", views: containerView)
        addConstraintWithFormat(format: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        containerView.addConstraintWithFormat(format: "H:|[v0][v1(80)]-12-|", views: nameLabel,timeLabel)
        containerView.addConstraintWithFormat(format: "V:|[v0][v1(24)]", views: nameLabel,messageLabel)
        
        containerView.addConstraintWithFormat(format: "V:|[v0(24)]", views: timeLabel)
        containerView.addConstraintWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)
        containerView.addConstraintWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel,hasReadImageView)
    }
}
extension UIView {
    
    func addConstraintWithFormat(format:String,views:UIView...)
    {
        var viewsDictionary = [String:UIView]()
        for(index,view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
class BaseCell:UICollectionViewCell
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews()
    {
       // backgroundColor = UIColor.blue
    }
}

