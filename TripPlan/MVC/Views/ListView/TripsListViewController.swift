//
//  TripsListViewController.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import UIKit

protocol TripsListViewControllerDelegate: AnyObject {
    func didBookTrip()
}

class TripsListViewController: UIViewController {
    
    @IBOutlet weak var mTableView: UITableView!
    let stationsManager = StationsManager()
    
    var tripsData : [StationsModel]?
    var tripId: Int? = 0
    
    weak var delegate: TripsListViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

 //MARK: - TableView Delegations
extension TripsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let id = tripId, let filteredData = tripsData?.first(where: { $0.id == id }){
            return filteredData.tripsCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripListViewCell", for: indexPath) as! TripListViewTableViewCell
        cell.delegate = self
        
        if let tripData = tripsData?.first(where: { $0.id == tripId }),
           indexPath.row < tripData.trips.count {
            let trip = tripData.trips[indexPath.row]
            cell.busNameLabel.text = trip.busName
            cell.timeLabel.text = trip.time
        }
        return cell
    }
}

//MARK: - TableviewCell Delegation

extension TripsListViewController: TripListViewCellDelegate {
    func bookButtonTapped(for cell: TripListViewTableViewCell) {
        guard let indexPath = mTableView.indexPath(for: cell),
              let tripData = tripsData?.first(where: { $0.id == tripId }),
              indexPath.row < tripData.trips.count else {
            return
        }
        
        let trip = tripData.trips[indexPath.row]
        let stationId = tripData.id
        let id = trip.id
        
        stationsManager.fetchTripData(stationId: stationId, tripId: id) { result in
            switch result {
            case .success:
                // write for image
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Trip booked successfully!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        self.delegate?.didBookTrip()
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
             
            case .failure:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "The trip you selected is full.", message: "Please select another one.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Select a Trip", style: .default, handler: nil)
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

