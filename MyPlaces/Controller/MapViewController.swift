//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Alexey Onoprienko on 06.03.2021.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    var mapManager = MapManager()
    var mapVCDelegate: MapViewControllerDelegate?
    var place = PlaceModel()
    
    let annotationIdentifier = "annotation"
    var receivedSegueIdentifier = ""
    var selectedAddress = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveAdressButton: UIButton!
    @IBOutlet weak var pinImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        
    }
    
    // Close map button
    @IBAction func closeMapButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Button for returning to current position
    @IBAction func currentPositionButton() {
        mapManager.showCurrentPosition(mapView: mapView)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        mapVCDelegate?.getAddress(selectedAddress)
        dismiss(animated: true)
    }
    
    
    
    private func setupMapView() {
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: receivedSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if receivedSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            pinImageView.isHidden = true
            saveAdressButton.isHidden = true
        }
    }

}

// MARK: - Map view delegate

extension MapViewController: MKMapViewDelegate {
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check that annotation is not MKUserLocation
        guard !(annotation is MKUserLocation) else { return nil }
        
        // Create annotation view
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            // Show annotation like banner
            annotationView?.canShowCallout = true
        }
        
        // Add image of place to annotation banner
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    // Get adress by chosen location
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let city = placemark?.locality
            let streetName = placemark?.thoroughfare
            let buildingNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if city != nil, streetName != nil, buildingNumber != nil {
                    self.selectedAddress = "\(city!), \(streetName!) \(buildingNumber!)"
                } else if city != nil, streetName != nil {
                    self.selectedAddress = "\(city!), \(streetName!)"
                } else if city != nil {
                    self.selectedAddress = "\(city!)"
                }
                
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    // Update authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: receivedSegueIdentifier)
    }
}
