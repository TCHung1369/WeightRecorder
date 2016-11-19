//
//  CoreDataHelper.swift
//  WeightRecorder
//
//  Created by Tzu_Chen on 25/10/16.
//  Copyright © 2016 Tzu-Chen. All rights reserved.
//

import UIKit
import  CoreData

class CoreDataHelper: NSObject {
    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
    let moc : NSManagedObjectContext?
    
    override init(){
     self.moc = self.appDelegate.persistentContainer.viewContext
    }
    
    public func saveContext(){
     self.appDelegate.saveContext()
    }
}
