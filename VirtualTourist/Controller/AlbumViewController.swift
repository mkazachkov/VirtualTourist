//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Mikhail on 11/10/20.
//

import UIKit
import MapKit
import CoreData

class AlbumViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var dataController: DataController!
    
    var pin: Pin!
    var span: MKCoordinateSpan!
    
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photos = pin.photos?.allObjects as! [Photo]
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        
        if !pin.albumCreated {
            createNewCollection()
        } else {
            collectionView.reloadData()
        }
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        createNewCollection()
    }
    
    func showSearchPhotosErrorAlert(message: String) {
        let alertViewController = UIAlertController(title: "Search Photos Error", message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertViewController, animated: true, completion: nil)
    }
    
    func createNewCollection() {
        setLoading(true)
        FlickrClient.searchRandomPhotos(pin: pin, completion: handleSearchPhotos(flickrPhotos:error:))
    }
    
    fileprivate func addPhotoFrom(_ flickrPhoto: FlickrPhoto) {
        let photo = Photo(context: self.dataController.viewContext)
        photo.id = flickrPhoto.id
        photo.server = flickrPhoto.server
        photo.secret = flickrPhoto.secret
        photo.pin = pin
        photos.append(photo)
    }
    
    fileprivate func createAlbumFrom(_ flickrPhotos: [FlickrPhoto]) {
        pin.albumCreated = true
        photos.forEach(dataController.viewContext.delete(_:))
        photos.removeAll()
        flickrPhotos.forEach(addPhotoFrom(_:))
        try? dataController.viewContext.save()
        collectionView.reloadData()
    }
    
    func handleSearchPhotos(flickrPhotos: [FlickrPhoto], error: Error?) {
        setLoading(false)
        if let error = error {
            showSearchPhotosErrorAlert(message: error.localizedDescription)
        } else {
            createAlbumFrom(flickrPhotos)
        }
    }
    
    func setLoading(_ loading: Bool) {
        if loading {
            newCollectionButton.isEnabled = false
            activityIndicator.startAnimating()
            noImagesLabel.isHidden = true
        } else {
            newCollectionButton.isEnabled = true
            activityIndicator.stopAnimating()
        }
    }
    
    fileprivate func getImageFromFlickr(photo: Photo, completion: @escaping (Data) -> Void) {
        guard let id = photo.id, let serverId = photo.server, let secret = photo.secret else {
            return
        }
        FlickrClient.getImage(id: id, serverId: serverId, secret: secret) { (image, error) in
            guard let image = image else {
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noImagesLabel.isHidden = !pin.albumCreated || photos.count != 0
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.imageView.image = UIImage(named: "VirtualTourist_120")
        
        let photo = photos[indexPath.row]

        if let image = photo.image {
            cell.imageView.image = UIImage(data: image)
        } else {
            getImageFromFlickr(photo: photo) { image in
                photo.image = image
                try? self.dataController.viewContext.save()
                cell.imageView.image = UIImage(data: image)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.delete(photos[indexPath.row])
        try? dataController.viewContext.save()
        photos.remove(at: indexPath.row)
        collectionView.reloadData()
    }
}
