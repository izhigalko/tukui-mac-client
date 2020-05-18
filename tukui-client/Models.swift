//
//  Models.swift
//  tukui-client
//
//  Created by Ilia Zhigalko on 07.04.2020.
//  Copyright © 2020 Ilya Zhigalko. All rights reserved.
//

import Foundation


struct AppError: LocalizedError {
    let message: String!

    var errorDescription: String? {
        self.message
    }
}

final class ApplicationContext {
    let installed: InstalledAddonsService!
    let api: TukUIApiClient! = TukUIApiClient()
    
    init(wowPath: String) {
        self.installed = InstalledAddonsService(wowPath: wowPath)
    }
    
    func setup(_ onError: (Error) -> Void) -> Void {
        do {
            try self.installed.setup()
        } catch {
            onError(error)
        }
    }
}
