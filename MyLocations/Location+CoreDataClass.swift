//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/12.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject,MKAnnotation {

    public var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    public var title: String?{
        if locationDescription.isEmpty{
            return "(No Description)"
        }else{
            return locationDescription
        }
    }
    public var subtitle: String?{
        return category
    }
    
}
