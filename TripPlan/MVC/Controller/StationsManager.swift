//
//  StationsPresenter.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import Foundation

class StationsManager{
    
    //MARK: - Fetch The Annotations for on Map
    
    func fetchStations(completion: @escaping (Result<[StationsModel], Error>) -> Void){
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
    
    //MARK: - Fetch Data Book from TableviewCell
    func fetchTripData(stationId: Int, tripId: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: "https://demo.voltlines.com/case-study/6/stations/\(stationId)/trips/\(tripId)") else {
                print("Invalid URL")
                return
            }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
                "key1": "value1",
                "key2": "value2"
            ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
                print("Error creating request body: \(error)")
                return
        }
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let responseData = data {
                            completion(.success(responseData))
                        }
                    } else {
                        let statusCodeError = NSError(domain: "HTTPErrorDomain", code: httpResponse.statusCode, userInfo: nil)
                        completion(.failure(statusCodeError))
                    }
                }
            }
        task.resume()
    }
}
