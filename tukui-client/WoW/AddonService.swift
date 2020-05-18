//
//  AddonService.swift
//  tukui-client
//
//  Created by Ilia Zhigalko on 07.04.2020.
//  Copyright © 2020 Ilya Zhigalko. All rights reserved.
//

import Foundation

struct ApiError: LocalizedError {
    let message: String!

    var errorDescription: String? {
        self.message
    }
}

final class InstalledAddonsService {
    private let wowPath: NSString!
    private let addonsPath: NSString!
    private var addons: [LocalAddon] = []
    var isInitialized: Bool = false
    
    private var fileManager: FileManager = FileManager.default

    
    init(wowPath: String) {
        self.wowPath = wowPath as NSString
        self.addonsPath = self.wowPath.appendingPathComponent("Interface/AddOns") as NSString
    }
    
    func setup() throws {
        var isDiretory: ObjCBool = ObjCBool(true)
        let isAddonsPathExists: Bool = self.fileManager.fileExists(atPath: self.addonsPath as String, isDirectory: &isDiretory)
    
        if !isDiretory.boolValue || !isAddonsPathExists {
            throw AppError(message: "Addons path not found or not directory: \(String(self.addonsPath))")
        }
        
        self.addons = try self.fileManager.contentsOfDirectory(atPath: addonsPath as String).reduce(into: [LocalAddon]()) { addons, name in
            do {
                let addon: LocalAddon = try LocalAddon(addonsPath.appendingPathComponent(name))
                addons.append(addon)
            } catch {
                
            }
        }
        
        self.isInitialized = true
    }
    
    func isAddonInstalled(_ matcher: (LocalAddon) -> Bool) -> Bool {
        let filtered = self.addons.filter { (addon) -> Bool in
            return matcher(addon)
        }
        
        return filtered.count > 0
    }
}
