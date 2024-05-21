//
//  NetworkService.swift
//  meowle
//
//  Created by a.gorshchak on 03.02.2024.
//

import Foundation

private extension String {
    static let origin = {
        if ProcessInfo.processInfo.environment["UITests"] != nil {
            return "http://localhost:9080/"
        }
        return "https://meowle.fintech-qa.ru/api/"
    }()
}

enum NetworkServiceError: LocalizedError {
    case urlUnwrapping
    case dataUnwrapping(String)
    case backendError(String)
    
    var errorDescription: String? {
        switch self {
        case .urlUnwrapping:
            return "URL unwrapping"
        case .dataUnwrapping(let description):
            return "Data unwrapping error: " + description
        case .backendError(let description):
            return description
        }
    }
}

final class NetworkService {
    
    
    // Dependencies
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Public
    
    func loadSearchResults(for searchRequest: String, _ completion: @escaping (Result<[CatsGroup], Error>) -> Void) {
        guard let url = URL(string: .origin + "core/cats/search") else {
            completion(.failure(NetworkServiceError.urlUnwrapping))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("ru", forHTTPHeaderField: "Accept-Language")
        request.setValue("43", forHTTPHeaderField: "Content-Length")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        let unicodeSearchRequest = searchRequest.unicodeScalars.reduce(into: "") {
            $0.append($1.escaped(asASCII: true)
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
            )
        }
        request.httpBody = "{\"name\":\"\(unicodeSearchRequest)\",\"gender\":null,\"order\":\"asc\"}".data(using: .utf8)
        session.dataTask(with: request) { data, responce, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let data {
                do {
                    let result = try JSONDecoder().decode(CatsSearchResponce.self, from: data)
                    completion(.success(result.groups))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NetworkServiceError.dataUnwrapping("CatsSearchResponce")))
            }
        }.resume()
    }
    
    func loadAllNames(_ completion: @escaping (Result<[CatsGroup], Error>) -> Void) {
        guard let url = URL(string: .origin + "core/cats/allByLetter?limit=5") else {
            completion(.failure(NetworkServiceError.urlUnwrapping))
            return
        }
        let request = URLRequest(url: url)
        session.dataTask(with: request) { data, responce, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let data {
                do {
                    let result = try JSONDecoder().decode(CatsSearchResponce.self, from: data)
                    completion(.success(result.groups))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NetworkServiceError.dataUnwrapping("CatsSearchResponce")))
            }
        }.resume()
    }
    
    func loadRating(_ completion: @escaping (Result<RatingResponse, Error>) -> Void) {
        guard let url = URL(string: .origin + "likes/cats/rating") else {
            completion(.failure(NetworkServiceError.urlUnwrapping))
            return
        }
        let request = URLRequest(url: url)
        session.dataTask(with: request) { data, responce, error in
            if let error {
                print(error)
                return
            }
            if let data {
                do {
                    let result = try JSONDecoder().decode(RatingResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NetworkServiceError.dataUnwrapping("RatingResponse")))
            }
        }.resume()
    }
    
    func loadCat(by identifier: Int, _ completion: @escaping (Result<Cat, Error>) -> Void) {
        guard let url = URL(string: .origin + "core/cats/get-by-id?id=\(identifier)") else {
            completion(.failure(NetworkServiceError.urlUnwrapping))
            return
        }
        let request = URLRequest(url: url)
        session.dataTask(with: request) { data, responce, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let data {
                do {
                    let result = try JSONDecoder().decode(CatByIdResponce.self, from: data)
                    completion(.success(result.cat))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NetworkServiceError.dataUnwrapping("CatByIdResponce")))
            }
        }.resume()
    }
    
    func loadCatPhotosList(by identifier: Int, _ completion: @escaping (Result<[URL], Error>) -> Void) {
        guard let url = URL(string: .origin + "photos/cats/\(identifier)/photos") else {
            completion(.failure(NetworkServiceError.urlUnwrapping))
            return
        }
        let request = URLRequest(url: url)
        session.dataTask(with: request) { data, responce, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let images = (json["images"] as? [String])?.compactMap({
                   URL(string: "https://meowle.fintech-qa.ru/\($0)")
               }) {
                completion(.success(images))
            } else {
                completion(.failure(NetworkServiceError.dataUnwrapping("loadCatPhotosList")))
            }
        }.resume()
    }
    
    func uploadCatPhoto(
        for catId: Int,
        imageData: Data,
        _ completion: (() -> Void)?
    ) {
        guard let url = URL(string: .origin + "photos/cats/\(catId)/upload") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("ru", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        
        request.httpBody = createBodyWithParameters(
            parameters: [:],
            filePathKey: "file",
            imageDataKey: imageData,
            boundary: boundary
        )
        
        session.dataTask(with: request) { _, _, _ in
            completion?()
        }.resume()
    }
    
    func uploadNewCat(name: String, gender: String, _ completion: @escaping (Result<Cat, Error>) -> Void) {
        guard let url = URL(string: .origin + "core/cats/add") else {
            completion(.failure(NetworkServiceError.urlUnwrapping))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("ru", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        
        request.httpBody = "{\"cats\":[{\"name\":\"\(name)\",\"gender\":\"\(gender)\"}]}".data(using: .utf8)
        session.dataTask(with: request) { data, responce, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let data {
                do {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let err = (json["cats"]  as? [[String: Any]])?.first?["errorDescription"] as? String {
                        throw NetworkServiceError.backendError(err)
                    }
                    let result = try JSONDecoder().decode(UploadNewCatResponce.self, from: data)
                    if let cat = result.cats.first {
                        completion(.success(cat))
                    } else {
                        completion(.failure(NetworkServiceError.dataUnwrapping("UploadNewCatResponce")))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NetworkServiceError.dataUnwrapping("UploadNewCatResponce")))
            }
        }.resume()
    }
    
    func updateDescription(
        for identifier: Int,
        description: String,
        completion: (() -> Void)?
    ) {
        guard let url = URL(string: .origin + "core/cats/save-description") else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("ru", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        let json: [String: Any] = [
            "catId": identifier,
            "catDescription": description
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        session.dataTask(with: request) { _, _, _ in
            completion?()
        }.resume()
    }
    
    func likesRequest(identifier: Int, like: Bool?, dislike: Bool?) {
        guard let url = URL(string: .origin + "likes/cats/\(identifier)/likes") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("ru", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        var bodyString = ""
        if let like = like {
            bodyString += "\"like\":\(like.asString)"
        }
        if let dislike = dislike {
            if !bodyString.isEmpty {
                bodyString += ","
            }
            bodyString += "\"dislike\":\(dislike.asString)"
        }
        
        request.httpBody = "{\(bodyString)}".data(using: .utf8)
        
        session.dataTask(with: request).resume()
    }
    
    // MARK: - Private
    
    private func createBodyWithParameters(
        parameters: [String: String],
        filePathKey: String,
        imageDataKey: Data,
        boundary: String
    ) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        let filename = "catPhoto.jpeg"
        
        let mimetype = "image/jpeg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
}

// MARK: - Private

private extension Bool {
    
    var asString: String {
        self ? "true" : "false"
    }
}

private extension Data {

    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}
