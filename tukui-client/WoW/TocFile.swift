//
//  TocFile.swift
//  tukui-client
//
//  Created by Ilia Zhigalko on 07.04.2020.
//  Copyright © 2020 Ilya Zhigalko. All rights reserved.
//

import Foundation


struct LocalAddon {
    public let path: String!
    public let name: String!
    public let toc: [String: String]
    
    init(_ path: String) throws {
        let addonPath = path as NSString
        self.name = addonPath.lastPathComponent
        self.path = path
        self.toc = try LocalAddon.readToc("\(addonPath.appendingPathComponent(addonPath.lastPathComponent)).toc")
    }
    
    private static func readToc(_ path: String) throws -> [String: String] {
        let fm: FileManager = FileManager.default
        
        if !fm.isReadableFile(atPath: path) {
            throw AppError(message: "Can't read addon toc file \(path)")
        }
        
        return try String(contentsOfFile: path).components(separatedBy: "\n").reduce(into: [String: String]()) { into, line in
            if !line.starts(with: "##") {
                return
            }
            
            let pair = line.replacingOccurrences(of: "^##", with: "")
                .split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
                .map(String.init)
            
            if let key = pair.first, let value = pair.last {
                into[key] = value.trimmingCharacters(in: .whitespaces)
            }
        }
    }
}
