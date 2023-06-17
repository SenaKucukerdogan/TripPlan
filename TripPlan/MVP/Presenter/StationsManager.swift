//
//  StationsPresenter.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import Foundation

//https://demo.voltlines.com/case-study/6/stations


class StationsManager{
        
    func fetchStations(completion: @escaping (Result<[StationsModel], Error>)->()){
        guard let url = URL(string: "https://demo.voltlines.com/case-study/6/stations") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            if let error = error {
                completion(.failure(error))
            }
            
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode([StationsModel].self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
            
        }
        task.resume()
    }
    
}
