//
//  Net.swift
//  Bark
//
//  Created by Digit on 11/26/21.
//

import Cocoa
import Foundation

var urlSession = URLSession.shared

// Upload API Response Struct

struct JsonReply: Codable
{
    let shortcode: String
    let status: Int
}

// Multipart Data Functions

func sendFile(fileURL: URL, then completionHandler: @escaping (Result<String, BarkErrorType>) -> Void) {
    let uploadUrl = URL.init(string: "https://api.streamable.com/upload", relativeTo: nil).unsafelyUnwrapped
    
    do {
        let fileData = try Data(contentsOf: fileURL)
        sendPostRequest(to: uploadUrl, fileData: fileData, fileName: fileURL.lastPathComponent) { result in
            switch result {
            case .success:
                let jsonResponse = try? JSONDecoder().decode(JsonReply.self, from: result.get())
                if let shortCode = jsonResponse?.shortcode {
                    completionHandler(.success(shortCode))
                } else {
                    completionHandler(.failure(BarkErrorType.noShortCodeGiven))
                }
            case .failure:
                completionHandler(.failure(BarkErrorType.uploadFailed))
                return
            }
        }
    } catch {
        return
    }
}

func sendPostRequest(
    to url: URL,
    fileData: Data,
    fileName: String,
    then handler: @escaping (Result<Data, Error>) -> Void
) {
    // To ensure that our request is always sent, we tell
    // the system to ignore all local cache data:
    var request = URLRequest(
        url: url,
        cachePolicy: .reloadIgnoringLocalCacheData
    )
    
    // Fetch creds from the keychain
    let username = getStreamableUsername()
    let password = getStreamablePassword()
    let loginString = "\(username):\(password)"
    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

    let boundary = "Boundary-\(UUID().uuidString)"
    let httpBody = NSMutableData()
    
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    httpBody.append(convertFileData(fieldName: "file",
                                    fileName: fileName,
                                    mimeType: "application/octet-stream",
                                    fileData: fileData,
                                    using: boundary))
    httpBody.appendString("--\(boundary)--")
    
    request.httpMethod = "POST"
    request.httpBody = httpBody as Data

    
    let task = urlSession.dataTask(
        with: request,
        completionHandler: { data, response, error in
            if error != nil {
                NSLog(error.debugDescription)
                handler(.failure(BarkErrorType.uploadFailed))
            } else {
                handler(.success(data.unsafelyUnwrapped))
            }
        }
    )
    
    task.resume()
}

func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
    let data = NSMutableData()
    
    data.appendString("--\(boundary)\r\n")
    data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
    data.appendString("Content-Type: \(mimeType)\r\n\r\n")
    data.append(fileData)
    data.appendString("\r\n")
    
    return data as Data
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

