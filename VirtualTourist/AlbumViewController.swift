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
    
    var locationCoordinate: CLLocationCoordinate2D!
    var pinLocation: PinLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        pinLocation = PinLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        let regionRadius: CLLocationDistance = 10000
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        
        collectionView.dataSource = self
        
        FlickrClient.searchPhotos(pinLocation: pinLocation) { (photos, error) in
            print(photos)
            Model.photoAlbums[self.pinLocation] = photos
            self.collectionView.reloadData()
        }
    }
}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let pinLocation = PinLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        return Model.photoAlbums[pinLocation]?.count ?? 0
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
