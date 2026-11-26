//
//  ContactImageStorage.swift
//  App_01
//
//  Created by Nethra Kalaimani on 13/11/26.
//
import UIKit
import Foundation

nonisolated struct ContactImageStorage {
    
    enum ContactImageStorageError: Error {
        case invalidImageData
        case directoryUnavailable
        case imageFileNotFound
    }

    private static let fileManager = FileManager.default

    static func saveImage(
        _ imageData: Data,
        for contactID: UUID
    ) throws -> String {
        
        guard let uiImage = UIImage(data: imageData),
            let jpegData = uiImage.jpegData(compressionQuality: 0.90) else {
            throw ContactImageStorageError.invalidImageData
        }

        let directoryURLs = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )

        guard let appSupportURL = directoryURLs.first else {
            throw ContactImageStorageError.directoryUnavailable
        }

        let photosDirectoryURL = appSupportURL.appendingPathComponent(
            "ContactPhotos",
            isDirectory: true
        )

        
        try fileManager.createDirectory(
            at: photosDirectoryURL,
            withIntermediateDirectories: true
        )
        let fileName = "\(contactID.uuidString).jpg"
        let imageURL = photosDirectoryURL.appendingPathComponent(fileName)

        
        try jpegData.write(
            to: imageURL,
            options: .atomic
        )
        
        return fileName
    }
    
    
    static func loadImage(named fileName: String) throws -> Data {
        let directoryURLs = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        
        guard let appSupportURL = directoryURLs.first else {
            throw ContactImageStorageError.directoryUnavailable
        }
        
        let photosDirectoryURL = appSupportURL.appendingPathComponent(
            "ContactPhotos",
            isDirectory: true
        )
        
        let imageURL = photosDirectoryURL.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: imageURL.path) else {
            throw ContactImageStorageError.imageFileNotFound
        }
        
        let data = try Data(contentsOf: imageURL)
        return data
    }
    
    
    static func deleteImage(named fileName: String) throws {
        let directoryURLs = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        
        guard let appSupportURL = directoryURLs.first else {
            throw ContactImageStorageError.directoryUnavailable
        }
        
        let photosDirectoryURL = appSupportURL.appendingPathComponent(
            "ContactPhotos",
            isDirectory: true
        )
        
        let imageURL = photosDirectoryURL.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: imageURL.path) else {
            throw ContactImageStorageError.imageFileNotFound
        }
        
        try fileManager.removeItem(at: imageURL)
    }
    
    
    
}
