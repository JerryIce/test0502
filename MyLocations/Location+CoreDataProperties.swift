//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/12.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import UIKit

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
    //coreData实例的各属性
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: NSDate
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var locationDescription: String
    @NSManaged public var photoID:NSNumber?
    
    var hasPhoto:Bool{
        return photoID != nil
    }
    var photoPath:String{
        assert(photoID != nil,"No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return (applicationDocumentsDirectory as NSString).appendingPathComponent(filename)
    }
    var photoImage:UIImage?{
        return UIImage(contentsOfFile: photoPath)
    }
    class func nextPhotoID()-> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    func removePhtotFile(){
        if hasPhoto{
            let path = photoPath
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path){
                do {
                    try fileManager.removeItem(atPath: path)
                }catch{
                    print("Error removing file:\(error)")
                }
            }
        }
    }
}
