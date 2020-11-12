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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        let regionRadius: CLLocationDistance = 10000
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }

}
