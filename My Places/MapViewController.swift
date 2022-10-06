//
//  MapViewController.swift
//  My Places
//
//  Created by Roma Bogatchuk on 05.10.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    var mapViewControllerDelegate: MapViewControllerDelegate?
    let annotationIdentifier = "annotationIdentifier"
    var place = Place()
    let locationManager = CLLocationManager()
    let regionInMeters = 10000.0
    var incomeSegueIdentifier = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var mapPinImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addressLabel.text = ""
        setupMapView()
        checkLocationAuthorization()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func centerViewInUserLocation(_ sender: UIButton) {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func showUserLocation(){
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func setupMapView(){
        if incomeSegueIdentifier == "showAddress" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
        print(incomeSegueIdentifier)
    }
    
    private func setupPlacemark(){
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard  let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    //ПРоверка включе ли сервис локации
    private func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Location services are Disable",
                          message: "To give permission Go to: Setting -> MyPlace -> Location")
            }
        }
    }
    
  
    
    private func setupLocationManager(){
        //точно определения местоположения
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    private func checkLocationAuthorization(){
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Your location is not Availeble",
                          message: "To give permission Go to: Setting -> MyPlace -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
      
        @unknown default:
            print("")
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitud = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitud)
    }
    
    private func showAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
        
    }

}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            imageView.layer.cornerRadius = 10
            imageView.image = UIImage(data: imageData)
            imageView.clipsToBounds = true
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            
            if let error = error {
                print(error)
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil{
                    self.addressLabel.text = "\(streetName!)"
                }else{
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
 
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
