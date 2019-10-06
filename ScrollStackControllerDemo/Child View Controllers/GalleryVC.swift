//
//  GalleryVC.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 04/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

public class GalleryVC: UIViewController, ScrollStackContainableController {
    
    @IBOutlet public var collectionView: UICollectionView!
    @IBOutlet public var pageControl: UIPageControl!

    public var urls: [URL] = [
        URL(string: "http://cdn.luxuo.com/2011/05/Aerial-view-luxury-Burj-Al-Arab.jpg")!,
        URL(string: "https://mediastream.jumeirah.com/webimage/heroactual//globalassets/global/hotels-and-resorts/dubai/burj-al-arab/rooms/new-royal-two-berdoom-suite/burj-al-arab-royal-suite-staircase-5-hero.jpg")!,
        URL(string: "https://mediastream.jumeirah.com/webimage/image1152x648//globalassets/global/hotels-and-resorts/dubai/burj-al-arab/rooms/new-sky-one-bedroom-suite/2019/burj-al-arab-jumeirah-sky-one-bedroom-suite-living-room-desktop.jpeg")!,
        URL(string: "https://q-xx.bstatic.com/xdata/images/hotel/max500/200178877.jpg?k=229a02237c3998ac6e8b11daae254113268e779e49ab2d18964f2e97bdc947a0&o=")!
    ]
        
    public static func create() -> GalleryVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "GalleryVC") as! GalleryVC
        return vc
    }
    
    public func scrollStackRowSizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> ScrollStack.ControllerSize? {
        return .fixed(300)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    public func reloadContentFromStackViewRow() {
        
    }

    private func reloadData() {
        pageControl.numberOfPages = urls.count
        collectionView.reloadData()
    }
    
}

extension GalleryVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.url = urls[indexPath.item]
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.item
    }
    
    
}

public class GalleryCell: UICollectionViewCell {
    
    @IBOutlet public var imageView: UIImageView!
    
    private var dataTask: URLSessionTask?
    
    public var url: URL? {
        didSet {
            dataTask?.cancel()

            guard let url = url else {
                self.imageView.image = nil
                return
            }
            
            dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
                let image = (data != nil ? UIImage(data: data!) : nil)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
            dataTask?.resume()
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.url = nil
    }
    
}
