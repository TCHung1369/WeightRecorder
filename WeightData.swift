//
//  WeightData.swift
//  WeightRecorder
//
//  Created by Tzu_Chen on 19/10/16.
//  Copyright © 2016 Tzu-Chen. All rights reserved.
//

import UIKit
import CoreData

class WeightData : NSManagedObject {

    @NSManaged var bmiData:Float
    @NSManaged var fatRate:Float
    @NSManaged var height:Float
    @NSManaged var weight:Float
    @NSManaged var image : Data
    @NSManaged var dateData : Date
    
}
