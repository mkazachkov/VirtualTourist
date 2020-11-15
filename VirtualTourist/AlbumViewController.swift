//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Mikhail on 11/10/20.
//

import UIKit
import MapKit

class AlbumViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var locationCoordinate: CLLocationCoordinate2D!
    var pinLocation: PinLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noImagesLabel.isHidden = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        pinLocation = PinLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        let regionRadius: CLLocationDistance = 1000
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        
        collectionView.dataSource = self
        
        let modelPhotos = Model.photoAlbums[pinLocation]
        
        if modelPhotos == nil {
            newCollectionButton.isEnabled = false
            activityIndicator.startAnimating()
            FlickrClient.searchPhotos(pinLocation: pinLocation) { (photos, error) in
                self.activityIndicator.stopAnimating()
                self.newCollectionButton.isEnabled = true
                
                if let error = error {
                    self.showSearchPhotosErrorAlert(message: error.localizedDescription)
                } else {
                    if photos.count == 0 {
                        self.noImagesLabel.isHidden = false
                    }
                    print(photos)
                    Model.photoAlbums[self.pinLocation] = photos
                    self.collectionView.reloadData()
                }
            }
        }
        
        if modelPhotos?.count == 0 {
            self.noImagesLabel.isHidden = false
        } else {
            self.collectionView.reloadData()
        }
    }
    
    func showSearchPhotosErrorAlert(message: String) {
        let alertViewController = UIAlertController(title: "Search Photos Error", message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        newCollectionButton.isEnabled = false
        activityIndicator.startAnimating()
        FlickrClient.searchPhotos(pinLocation: pinLocation) { (photos, error) in
            self.activityIndicator.stopAnimating()
            self.newCollectionButton.isEnabled = true
            
            if let error = error {
                self.showSearchPhotosErrorAlert(message: error.localizedDescription)
            } else {
                if photos.count == 0 {
                    self.noImagesLabel.isHidden = false
                }
                print(photos)
                Model.photoAlbums[self.pinLocation] = photos
                self.collectionView.reloadData()
            }
        }
    }
    
}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let pinLocation = PinLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        let numberOfItems = Model.photoAlbums[pinLocation]?.count ?? 0
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let pinLocation = PinLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        let photo = Model.photoAlbums[pinLocation]![indexPath.row]
        
        
        FlickrClient.getImage(id: photo.id, serverId: photo.server, secret: photo.secret) { (image, error) in
            cell.imageView.image = image
        }
        
        return cell
    }
}
