//
//  ViewController.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import UIKit
import MapKit

class ViewController: UIViewController, TripsListViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listTripsButton: UIButton!
 
    
    private lazy var locationManager : CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.startUpdatingLocation()
        return manager
    }()
    
    private lazy var stationsManager : StationsManager = {
        return StationsManager()
    }()
    
    
    private var centerCoordinates = String()
    private var latitude = String()
    private var longitude = String()
    private var annotationId = Int()
    private var tripsCount = 0
    private var selectedAnnotationId: Int? = 0
    private var stationsModelData = [StationsModel]()
    
    private var selectedAnnotationView: MKAnnotationView?

    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        fetchData()
        
        listTripsButton.isHidden = true
    }
    
    private func configureMapView(){
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    //MARK: - Data Fetching
    
    private func fetchData() {
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
    
    // MARK: - Actions
    
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
    
    // MARK: - Helper Methods
    
    private func parseCenterCoordinates(_ centerCoordinates: String) -> (String, String){
        let components = centerCoordinates.components(separatedBy: ",")
        
        if components.count == 2 {
            latitude = components[0] // Value before the comma
            longitude = components[1] // Value after the comma
            return (latitude, longitude)
        } else {
            print("Invalid string format")
            return("","")
        }
    }
    
    // MARK: - Trip Booking Delegate
    
    func didBookTrip() {
        self.dismiss(animated: true, completion: nil)
        selectedAnnotationView?.image = UIImage(named: "Completed")
    }
}


extension ViewController: CLLocationManagerDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: false)
    }
}


extension ViewController: MKMapViewDelegate{
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
        
        stationAnnotationView?.image = UIImage(named: "Point")
    
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
        data.forEach { stationData in
            let annotation = MKPointAnnotation()
            annotationId = stationData.id
            let (latitude, longitude) = parseCenterCoordinates(stationData.centerCoordinates)
            if let latitude = Double(latitude), let longitude = Double(longitude){
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            annotation.title = "\(stationData.tripsCount) Trips"
            mapView.addAnnotation(annotation)
        }
    }
}

