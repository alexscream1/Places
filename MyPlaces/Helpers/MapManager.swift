//
//  MapManager.swift
//  MyPlaces
//
//  Created by Alexey Onoprienko on 07.03.2021.
//

import UIKit
import MapKit


class MapManager {
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    
    
    func setupPlacemark(place: PlaceModel, mapView: MKMapView) {
        
        // Check if location exists
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            // Check for errors
            if let error = error {
                print(error)
                return
            }
            
            // Check if placemarks exist
            guard let placemarks = placemarks else { return }
            
            // We should have only one placemark, because we use our location
            let placemark = placemarks.first
            
            // Create annotation to describe our point on map
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            
            // Position of marker
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Check if location services enabled
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.disabledServicesAlert(title: "Location services are disable", message: "Activate: Settings -> Privacy -> Location Service -> Turn On")
            }
            
        }
    }
    
    // Check location authorization
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "showPosition" { showCurrentPosition(mapView: mapView) }
            break
        case .authorizedAlways :
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.disabledServicesAlert(title: "Your location is not available", message: "Go: Settings -> MyPlaces -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    // Function to show current position of user
    func showCurrentPosition(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Get center point of map
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longtitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longtitude)
    }
    
    // Alert when location services disabled
    private func disabledServicesAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okayAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
}
