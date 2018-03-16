//
//  FriendsCotrollerHelper.swift
//  facebookMessanger
//
//  Created by magdy on 3/9/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
//class Message : NSObject{
//    var text:String?
//    var date:NSDate?
//    var friend:Friend?
//}
//class Friend :NSObject{
//    var name:String?
//    var profileImage:String?
//}
import CoreData
extension FriendsController{
    
    
    func clearData()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext
        {
            do{
            let entityNames = ["Friend","Message"]
            
            for entityName in entityNames{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            if let objects = try(context.fetch(fetchRequest)) as?[NSManagedObject]
            {
            
                for object in objects
                {
                    context.delete(object)
                }
            }
            
            
            //saving data to disk
            try(context.save())
                
            }
            }catch let err{
                print(err)
            
            
            
            }
        }
    }
     func setupData(){
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext
        {
        
        
        let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context)as! Friend
        //let mark = Friend(context: context)
        mark.name = "mark FaceBook"
        mark.profileImage = "myimage"
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context)as! Message
        message.friend = mark
        message.date = NSDate()
        message.text = "hello my friend are u  there ??"
        mark.lastMessage = message
        createSteveMessageWithContext(context:context)
        
        do{
            //saving data to disk
           try(context.save())
        }catch let err{
            print(err)
            }
       // messages = [message,messageSteve]
        
        }
        //loadData()
    }
    static func createMessageWithTex(text:String,friend:Friend,minutesAgo:Double,context:NSManagedObjectContext,isSender:Bool = false)->Message
    {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context)as! Message
        message.friend = friend
        message.date = NSDate().addingTimeInterval(-minutesAgo*60)
        message.text = text
        message.isSender = isSender
        friend.lastMessage = message
        return message
    }
    
    private func createSteveMessageWithContext(context:NSManagedObjectContext)
    {
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context)as! Friend
        //        let steve = Friend(context: context)
        steve.name = "steve FaceBook"
        steve.profileImage = "myimage"
        
        
        
        FriendsController.createMessageWithTex(text: "hello there aaaaaaaaaa dssss fjfjfj yguuiguigig guigui", friend: steve, minutesAgo: 4, context: context)
        FriendsController.createMessageWithTex(text: "hello my friend aaaaaaaaaa dssss fjfjfj yguuiguigig guigui", friend: steve, minutesAgo: 3, context: context,isSender: true)
        FriendsController.createMessageWithTex(text: "hello Are u there aaaaaaaaaa dssss fjfjfj yguuiguigig guigui", friend: steve, minutesAgo: 2, context: context)
        FriendsController.createMessageWithTex(text: "hello my friend aaaaaaaaaa dssss fjfjfj yguuiguigig guigui", friend: steve, minutesAgo: 1, context: context,isSender: true)
        FriendsController.createMessageWithTex(text: "hello my friend aaaaaaaaaa dssss fjfjfj yguuiguigig guigui", friend: steve, minutesAgo: 1, context: context,isSender: true)
        FriendsController.createMessageWithTex(text: "hello my friend aaaaaaaaaa dssss fjfjfj yguuiguigig guigui", friend: steve, minutesAgo: 1, context: context,isSender: true)
        FriendsController.createMessageWithTex(text: "hello my friend aaaaaaaaaa dssss fjfjfj yguuiguigig guigui", friend: steve, minutesAgo: 1, context: context,isSender: true)
    }
//    func loadData(){
//        
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        if let context = delegate?.persistentContainer.viewContext
//        {
//            if let friends = fetchFriends(){
//                messages = [Message]()
//                for friend in friends
//                {
//                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key:"date",ascending:false)]
//                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
//                    fetchRequest.fetchLimit = 1
//                    do{
//                    
//                    //saving data to disk
//                    let fetchMessages = try(context.fetch(fetchRequest))as?[Message]
//                    messages?.append(contentsOf: fetchMessages!)
//                    
//                    }catch let err{
//                    print(err)
//                    }
//                }
//                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
//            }
//            
//        }
//    }
//    private func fetchFriends()->[Friend]?
//    {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        if let context = delegate?.persistentContainer.viewContext
//        {
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
//            do{
//                
//                //saving data to disk
//                return try context.fetch(request) as? [Friend]
//                
//            }catch let err{
//                print(err)
//            }
//        }
//        return nil
//    }
}
