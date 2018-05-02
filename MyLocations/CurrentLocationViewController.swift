//
//  FirstViewController.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/7.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {
    //MARK:- 插座变量
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    //MARK:- 普通变量
    let locationManager = CLLocationManager()
    var location:CLLocation?
    var updateLocation = false
    var lastLocationError:NSError?
    let geocoder = CLGeocoder()
    var placemark:CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError:NSError?
    var timer: Timer?
    
    var managedObjectContext:NSManagedObjectContext!
    //MARK:- viewDidLoad初始化及内存警告
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateLabels()
        configureGetButton()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: segue方法
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as!LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
            
        }
    }
    
    
    //MARK:- 主要程序方法
    //MARK:获得许可，设置CLLocationManager，设置精度，打开manager
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        if updateLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }
    //MARK:定位允许许可判断
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "定位服务失败", message: "请打开定位权限", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    //MARK: 更新标签
    func updateLabels() {
        if let location = location{
            latitudeLabel.text = String(format:"%.8f",location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            if let placemark = placemark{
                addressLabel.text = stringFromPlacemark(placemark: placemark)
            }else if performingReverseGeocoding{
                addressLabel.text = "Searching for Address..."
            }else if lastGeocodingError != nil{
                addressLabel.text = "Error Finding Address"
            }else{
                addressLabel.text = "No Address Found"
            }
        }
        else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tag 'Get My Location'to start."
        }
        let statusMessage:String
        if let error = lastLocationError {
            if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                statusMessage = "Location Services Disabled"
            }
            else {
                statusMessage = "Error Getting Location"
            }
        } else if !CLLocationManager.locationServicesEnabled() {
            statusMessage = "Location Services Disabled"
        } else if updateLocation {
            statusMessage = "Searching..."
        } else {
            statusMessage = "Tap 'Get My Location' to Start"
        }
        messageLabel.text = statusMessage
    }
    //MARK:打开LocationManager
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updateLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(CurrentLocationViewController.didTimeOut), userInfo: nil, repeats: false)
        }
    }
    //MARK: 关闭locationManager
    func stopLocationManager(){
        if updateLocation{
            if let timer = timer{
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updateLocation = false
        }
    }
    //MARK: 配置按钮
    func configureGetButton(){
        if updateLocation{
            getButton.setTitle("stop", for: .normal)
        }else{
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    //MARK: 定位超时
    func didTimeOut(){
        print("Time Out")
        if location == nil{
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    //MARK:- 实现协议中方法：
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithErroe\(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError = error as NSError
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations\(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5{
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location{
            distance = newLocation.distance(from: location)
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            lastLocationError = nil
            location = newLocation
            updateLabels()
        }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
            print("We are done")
            stopLocationManager()
            configureGetButton()
            if distance > 0{
                performingReverseGeocoding = false
            }
        }
        //地理编码部分
        if !performingReverseGeocoding{
            print("Going to geocode...")
            performingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                placemarks, error in
                print("Found placemarks:\(String(describing: placemarks)),error:\(String(describing: error))")
                self.lastGeocodingError = error as NSError?
                if error == nil, let p = placemarks, !p.isEmpty {
                    self.placemark = p.last! }
                else {
                    self.placemark = nil }
                self.performingReverseGeocoding = false
                self.updateLabels()
            })
        }else if distance < 1.0{
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10{
                print("Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    //MARK:- 地理编码
    func stringFromPlacemark(placemark:CLPlacemark)->String{
        var line1 = ""
        line1.addText(text: placemark.subThoroughfare)
        line1.addText(text: placemark.thoroughfare, withSeparator: " ")
        var line2 = ""
        line2.addText(text: placemark.locality)
        line2.addText(text: placemark.postalCode,withSeparator: " ")
        line2.addText(text: placemark.administrativeArea, withSeparator: " ")
        line1.addText(text: line2, withSeparator: "\n")
        return line1
    }
    
    
}

