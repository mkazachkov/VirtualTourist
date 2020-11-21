//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Mikhail on 11/9/20.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var dataController: DataController!
    
    var annotations: [MKPointAnnotation:Pin] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            let latitude = UserDefaults.standard.double(forKey: "latitude")
            let longitude = UserDefaults.standard.double(forKey: "longitude")
            let latitudeDelta = UserDefaults.standard.double(forKey: "latitudeDelta")
            let longitudeDelta = UserDefaults.standard.double(forKey: "longitudeDelta")
            
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            mapView.setRegion(region, animated: true)
            
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                for pin in result {
                    let annotation = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    annotation.coordinate = coordinate
                    annotations[annotation] = pin
                }
                mapView.addAnnotations(Array(annotations.keys))
            }
        } else {
            saveRegion(mapView)
            UserDefaults.standard.setValue(true, forKey: "hasLaunchedBefore")
        }
    }
    
    @IBAction func dropNewPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchLocation = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = locationCoordinate.latitude
            pin.longitude = locationCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationCoordinate
            mapView.addAnnotation(annotation)
            
            annotations[annotation] = pin
            try? dataController.viewContext.save()
        }
    }
    
    func saveRegion(_ mapView: MKMapView) {
        UserDefaults.standard.setValue(mapView.region.center.latitude, forKey: "latitude")
        UserDefaults.standard.setValue(mapView.region.center.longitude, forKey: "longitude")
        UserDefaults.standard.setValue(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.setValue(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let albumViewController = segue.destination as! AlbumViewController
        albumViewController.dataController = dataController
        let annotation = sender as! MKPointAnnotation
        albumViewController.pin = annotations[annotation]
        albumViewController.span = mapView.region.span
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: "showAlbum", sender: view.annotation)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveRegion(mapView)
    }
}

