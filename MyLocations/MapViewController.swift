//
//  MapViewController.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/29.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    //MARK:- 属性变量
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext:NSManagedObjectContext!{
        didSet{
            NotificationCenter.default.addObserver(forName:NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main, using: {notification in
                if self.isViewLoaded{
                    self.updateLocations()
                }
            })
        }
    }
    var locations = [Location]()
    //MARK:- 界面初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        if !locations.isEmpty{
            showLocations()
        }
        
    }
    //MARK:- 按键函数
    @IBAction func showLocations() {
        let region = regionForAnnotations(annotations: locations)
        mapView.setRegion(region, animated: true)
    }
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    //MARK:- 地图设置
    func updateLocations(){
        mapView.removeAnnotations(locations)
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        locations = try! managedObjectContext.fetch( fetchRequest) as! [Location]
        mapView.addAnnotations(locations)
    }
    func regionForAnnotations(annotations:[MKAnnotation]) -> MKCoordinateRegion {
        var region:MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations[annotations.count-1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2DMake(-90, 180)
            var bottomRightCoord = CLLocationCoordinate2DMake(90, -180)
            for annotation in annotations{
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            let center = CLLocationCoordinate2DMake(topLeftCoord.latitude-(topLeftCoord.latitude-bottomRightCoord.latitude)/2, topLeftCoord.longitude-(topLeftCoord.longitude-bottomRightCoord.longitude)/2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude-bottomRightCoord.latitude)*extraSpace, longitudeDelta: abs(topLeftCoord.longitude-bottomRightCoord.longitude)*extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
    return mapView.regionThatFits(region)
    }
    
    
    
}
extension MapViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //判断是否是Location类的位置对象
        guard annotation is Location else{
            return nil
        }
//      创建annotion view对象
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: (identifier)) as! MKPinAnnotationView!
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.isEnabled = true
            annotationView?.canShowCallout = true
            annotationView?.animatesDrop = false
            annotationView?.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            annotationView?.tintColor = UIColor(white: 0.0, alpha: 0.5)
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            annotationView?.rightCalloutAccessoryView = rightButton
        }else{
            annotationView?.annotation = annotation
        }
        let button = annotationView?.rightCalloutAccessoryView as! UIButton
        if let index = locations.index(of: annotation as! Location){
            button.tag = index
        }
        return annotationView
    }
    func showLocationDetails(sender:UIButton){
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
}
extension MapViewController:UINavigationBarDelegate{
    func positionForBar(bar:UIBarPosition)->UIBarPosition{
        return .topAttached
    }
}
