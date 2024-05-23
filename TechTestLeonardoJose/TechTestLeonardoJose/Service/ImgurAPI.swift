//
//  ImgurAPI.swift
//  TechTestLeonardoJose
//
//  Created by Leonardo Jose Gunawan on 23/05/24.
//

import Foundation
import UIKit

class ImgurAPI {
    let clientID = "a1dc19876e045f74dca128d148d2854a06c5bf40"
    let username = "leonardojose472"
    
    // MARK: READ
    func fetchImages(completion: @escaping ([ImgurImage]?) -> Void) {
        var allImages = [ImgurImage]()
        var page = 0

        func fetchPage() {
            let urlString = "https://api.imgur.com/3/account/\(username)/images/\(page)"
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(clientID)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    print("Raw JSON data:", String(data: data, encoding: .utf8) ?? "No data")
                    let result = try JSONDecoder().decode([String: [ImgurImage]].self, from: data)
                    if let images = result["data"] {
                        allImages.append(contentsOf: images)
                        if images.count == 0 {
                            completion(allImages)
                        } else {
                            page += 1
                            fetchPage()
                        }
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                }
            }.resume()
        }

        fetchPage()
    }
    
    // MARK: CREATE
    func uploadImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert image to data")
            completion(false)
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        let urlString = "https://api.imgur.com/3/image"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(clientID)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "image=\(base64Image)"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool {
                    completion(success)
                } else {
                    print("Failed to parse response")
                    completion(false)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(false)
            }
        }.resume()
    }
    
    // MARK: UPDATE
    func updateImage(imageHash: String, title: String?, description: String?, completion: @escaping (Bool) -> Void) {
        let urlString = "https://api.imgur.com/3/image/\(imageHash)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID d98122a3559ef1a", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var bodyString = ""
        if let title = title {
            bodyString += "title=\(title)&"
        }
        if let description = description {
            bodyString += "description=\(description)"
        }
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating image: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool {
                    completion(success)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }
    
    // MARK: DELETE
    func deleteImage(imageHash: String, completion: @escaping (Bool) -> Void) {
        let urlString = "https://api.imgur.com/3/image/\(imageHash)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(clientID)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting image: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool {
                    completion(success)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }
}
