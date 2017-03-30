//
//  ResultTableViewCell.swift
//  QuickSearch
//
//  Created by 何子龙 on 04/02/2017.
//  Copyright © 2017 何子龙. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    var item: result! {
        didSet {
            self.updateUI()
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var PostImageView: UIImageView!
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var castsLabel: UILabel!

    // MARK: Actions
    
    func updateUI() {
        titleLabel.text = item.movieName
        ratingLabel.text = item.detail
        castsLabel.text = item.casts
        
        PostImageView.imageFromServerURL(urlString: item.imageUrl)
    
        backgroundCardView.backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        
//        backgroundCardView.layer.cornerRadius = 3.0
        backgroundCardView.layer.masksToBounds = false
        
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image?.resizeImage(newWidth: CGFloat(65.0))
            })
            
        }).resume()
    }}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    } }
