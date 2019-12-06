//
//  TukUIApiClient.swift
//  tukui-client
//
//  Copyright © 2019 Ilya Zhigalko. All rights reserved.
//

import Foundation

final class TukUIApiClient: NSObject {
    private let session: URLSession = URLSession(configuration: .default)
    private let decoder: JSONDecoder = JSONDecoder()

    func searchAddons(startsWith: String?,
                      onComplete: (@escaping ([Addon]) -> Void),
                      onError: (@escaping (Error) -> Void)) {
        let request = PluginListApiRequest(self.session, self.decoder, onComplete, onError)

        request.call() {
            URL(string: "https://www.tukui.org/api.php?addons=all")
        }
    }
}

struct ApiError: LocalizedError {
    let message: String!

    var errorDescription: String? {
        self.message
    }
}

protocol ApiRequest {
    associatedtype T

    init(_ session: URLSession!, _ decoder: JSONDecoder!, _ onComplete: ((T) -> Void)!, _ onError: ((Error) -> Void)!)
    func deserialize(_: Data) throws -> T
}

class ApiRequestBase<T>: ApiRequest {
    private let session: URLSession
    private let onComplete: ((T) -> Void)
    private let onError: ((Error) -> Void)
    internal let decoder: JSONDecoder

    required init(_ session: URLSession!, _ decoder: JSONDecoder!,
                  _ onComplete: ((T) -> Void)!, _ onError: ((Error) -> Void)!) {
        self.session = session
        self.decoder = decoder
        self.onComplete = onComplete
        self.onError = onError
    }

    internal func deserialize(_ data: Data) throws -> T {
        fatalError("deserialize(_:) has not been implemented")
    }

    internal func call(_ getUrl: () -> URL?) {
        guard let url = getUrl() else {
            return onError(ApiError(message: "Can't construct url"))
        }

        self.session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                return self.onError(error)
            }

            guard response != nil else {
                return self.onError(ApiError(message: "No response from server"))
            }

            guard let data = data else {
                return self.onError(ApiError(message: "Empty server response data"))
            }

            do {
                let result = try self.deserialize(data)
                self.onComplete(result)
            } catch {
                self.onError(error)
            }
        }.resume()
    }
}

class PluginListApiRequest: ApiRequestBase<[Addon]> {
    internal override func deserialize(_ data: Data) throws -> T {
        try self.decoder.decode([Addon].self, from: data)
    }
}
