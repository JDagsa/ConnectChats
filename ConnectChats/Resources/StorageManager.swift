//
//  StorageManager.swift
//  ConnectChats
//
//  Created by Jayden Dagsa on 2/5/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/jayden-dagsa-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to Firebase storage and returns completion with URL string to download.
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                // Failed.
                print("Failed to upload data to Firebase Storage for picture")
                completion(.failure(storageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download URL from Firebase Storage")
                    completion(.failure(storageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
            })
        })
    }
    
    public enum storageErrors: Error {
        /// Case used when there is a failure to upload to Firebase Storage.
        case failedToUpload
        /// Case used when there is a failure to get the download URL from Firebase Storage.
        case failedToGetDownloadURL
    }
    
}
