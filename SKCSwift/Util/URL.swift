//
//  URL.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/17/25.
//

import Foundation

extension URL {
    func calculateDirectorySize(exclude protectedDirs: Set<String> = Set(), manager fileManager: FileManager) throws -> UInt64  {
        var dirSize: UInt64 = 0
        let urlKeys: [URLResourceKey] = [.isDirectoryKey, .totalFileAllocatedSizeKey]
        let files = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: urlKeys)
        
        for file in files {
            let resourceValues = try file.resourceValues(forKeys: Set(urlKeys))
            if let isDirectory = resourceValues.isDirectory, isDirectory {
                if !protectedDirs.contains(file.lastPathComponent.lowercased()) {
                    dirSize += try file.calculateDirectorySize(exclude: protectedDirs,
                                                          manager: fileManager)
                }
            } else if let fileSize = resourceValues.totalFileAllocatedSize {
                dirSize += UInt64(fileSize)
            }
        }
        return dirSize  // in bytes
    }
    
    func deleteContents(exclude protectedDirs: Set<String> = Set(), manager fileManager: FileManager) throws {
        let files = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)
        
        for file in files {
            if !protectedDirs.contains(file.lastPathComponent.lowercased()) {
                try fileManager.removeItem(at: file)
            }
        }
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
}
