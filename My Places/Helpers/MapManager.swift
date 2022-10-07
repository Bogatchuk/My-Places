//
//  MapManager.swift
//  My Places
//
//  Created by Roma Bogatchuk on 07.10.2022.
//

import UIKit
import MapKit

class MapManager{
    let locationManager = CLLocationManager()
    private let regionInMeters = 1000.0
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    
    //Маркер заведения
    func setupPlacemark(place: Place, mapView: MKMapView){
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //Проверка включе ли сервис геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> () ){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Location services are Disable",
                          message: "To give permission Go to: Setting -> MyPlace -> Location")
            }
        }
    }
    
    //Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String){
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    //Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView){
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previusLocation: (CLLocation) -> ()){
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previusLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Destination is not available")
                return
            }
            
            for router in response.routes {
                mapView.addOverlay(router.polyline)
                mapView.setVisibleMapRect(router.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", router.distance / 1000)
                let timeInterval = router.expectedTravelTime * 60
                
                print("Растояние до места \(distance)км.  и приблизительное время \(timeInterval) мин.")
            }
        }
        
    }
    
    //Настройка запроса для расчета маршрута
    func createDirectionsRequest(from cordination: CLLocationCoordinate2D) -> MKDirections.Request?{
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: cordination)
        let destinaition = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinaition)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
        
    }
    
    //Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView,
                                           and location: CLLocation?,
                                           closure: (_ currentLocation: CLLocation) -> ()){
        
        guard let location = location else { return }
        let centr = getCenterLocation(for: mapView)
        guard centr.distance(from: location) > 50 else { return }
        
        closure(centr)
    }
    
    //Сброс всех ранее построенных маршрутов перед посмтройкой нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView){
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map{$0.cancel()}
        directionsArray.removeAll()
    }
    
    //Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitud = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitud)
    }
    
    
    func showAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
}
