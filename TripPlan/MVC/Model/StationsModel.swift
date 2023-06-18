//
//  StationsModel.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import Foundation

struct StationsModel: Codable {
    
    let centerCoordinates: String
    let id: Int
    let name: String
    let trips: [Trip]
    let tripsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case centerCoordinates = "center_coordinates"
        case id, name, trips
        case tripsCount = "trips_count"
    }
}

struct Trip: Codable {
    let busName: String
    let id: Int
    let time: String
    
    enum CodingKeys: String, CodingKey {
        case busName = "bus_name"
        case id, time
    }
}


