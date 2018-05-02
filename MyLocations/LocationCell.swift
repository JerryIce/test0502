//
//  LocationCell.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/16.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.black
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width/2
        photoImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureForLocation(_ location:Location){
        if location.locationDescription.isEmpty{
            descriptionLabel.text = "(No Description)"
        }else{
            descriptionLabel.text = location.locationDescription
        }
        if let placemark = location.placemark{
            var text = ""
            text.addText(text: placemark.subThoroughfare)
            text.addText(text: placemark.thoroughfare, withSeparator: " ")
            text.addText(text: placemark.locality, withSeparator: ", ")
            addressLabel.text = text
        }else{
            addressLabel.text = String(format: "Lat:%.8f,Long:%.8f", location.latitude,location.longitude)
        }
        photoImageView.image = imageForLocation(location: location)
    }
    func imageForLocation(location:Location)->UIImage{
        if location.hasPhoto, let image = location.photoImage{
            return image.resizedImageWithBounds(bounds: CGSize(width: 53, height: 52))
        }
        return UIImage()
    }

}
