//
//  ViewController.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var listTripsButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        addAnnotation()
        
        listTripsButton.isHidden = true
    }
    
    @IBAction func listTripsButton(_ sender: Any) {
        
    }
    


}

extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        
        mapView.setRegion(region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var stationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "StationAnnotationView")
        
        if stationAnnotationView == nil {
            stationAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "StationAnnotationView")
            stationAnnotationView?.canShowCallout = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(annotationTapped(_:)))
            stationAnnotationView?.addGestureRecognizer(tapGesture)
        } else {
            stationAnnotationView?.annotation = annotation
        }
        
        
        stationAnnotationView?.image = UIImage(named: "Point") // notation a tıklanınca image değişecek ve buton açılacak
    

        return stationAnnotationView
    }
    
    @objc private func annotationTapped(_ sender: UITapGestureRecognizer) {
        if let annotationView = sender.view as? MKAnnotationView {

            annotationView.image = UIImage(named: "Selected Point")
            listTripsButton.isHidden = false
        }
    }
    
    func addAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.98496675, longitude: 29.101067799999996) //modelden çekilecek
        annotation.title = "9 Trips" // modelden trip count çekilecek
        mapView.addAnnotation(annotation) // array tanımlanacak
    }
    
}

