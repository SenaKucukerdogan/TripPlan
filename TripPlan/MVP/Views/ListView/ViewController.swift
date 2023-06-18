//
//  ViewController.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, TripsListViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listTripsButton: UIButton!
    
    let locationManager = CLLocationManager()
    let stationsManager = StationsManager()
    
    var centerCoordinates = String()
    var tripsCount = 0
    var latitude = String()
    var longitude = String()
    var annotationId = Int()
    var stationsModelData = [StationsModel]()
    var selectedAnnotationId: Int? = 0
    
    var selectedAnnotationView: MKAnnotationView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        listTripsButton.isHidden = true
        
        fetchData()

    }
    
    func didBookTrip() {
        
        self.dismiss(animated: true, completion: nil)
        selectedAnnotationView?.image = UIImage(named: "Completed")
    }
    
    
    func fetchData() {
        stationsManager.fetchStations { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.stationsModelData = data
                    self?.addAnnotation(data: data)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    @IBAction func listTripsButton(_ sender: Any) {
        performSegue(withIdentifier: "TripsListViewControllerSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "TripsListViewControllerSegue"{
            if let destination = segue.destination as? TripsListViewController{
                destination.modalPresentationStyle = .fullScreen
                destination.tripsData = stationsModelData
                destination.tripId = selectedAnnotationId
                destination.delegate = self
            }
        }
    }
    
    func parseCenterCoordinates(centerCoordinates: String) -> (String, String){
        let components = centerCoordinates.components(separatedBy: ",")
        
        if components.count == 2 {
            latitude = components[0] // Value before the comma
            longitude = components[1] // Value after the comma

        } else {
            print("Invalid string format")
        }
        return (latitude, longitude)
    }
    


}

extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
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
        if let annotationView = sender.view as? MKAnnotationView,
           let annotation = annotationView.annotation as? MKPointAnnotation {
            
            if let previousSelectedAnnotationView = selectedAnnotationView {
                previousSelectedAnnotationView.image = UIImage(named: "Point")
                
            }
            
            if annotationView == selectedAnnotationView {
                annotationView.image = UIImage(named: "Point")
                annotation.title = ""
                listTripsButton.isHidden = true
                selectedAnnotationView = nil
                selectedAnnotationId = nil
                
            } else {
                annotationView.image = UIImage(named: "Selected Point")
                listTripsButton.isHidden = false
                
                if let selectedAnnotation = stationsModelData.first(where: {$0.centerCoordinates == "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)" }) {
                    selectedAnnotationId = selectedAnnotation.id
                    annotation.title = "\(selectedAnnotation.tripsCount) Trips"
                }
                
                selectedAnnotationView = annotationView
            }
        }
    }

    func addAnnotation(data: [StationsModel]){
        stationsModelData.forEach { dataType in
            let annotation = MKPointAnnotation()
            annotationId = dataType.id
            latitude = parseCenterCoordinates(centerCoordinates: dataType.centerCoordinates).0
            longitude = parseCenterCoordinates(centerCoordinates: dataType.centerCoordinates).1
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0) //modelden çekilecek
            annotation.title = "\(dataType.tripsCount) Trips" // modelden trip count çekilecek
            mapView.addAnnotation(annotation) // array tanımlanacak
        }
        
    }
    
}

