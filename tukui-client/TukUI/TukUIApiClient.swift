//
//  TukUIApiClient.swift
//  tukui-client
//
//  Copyright © 2019 Ilya Zhigalko. All rights reserved.
//

import Foundation

final class TukUIApiClient {
    private let session: URLSession! = URLSession(configuration: .default)
    private let decoder: JSONDecoder! = JSONDecoder()
    private let getAllAddonsReq: GetAllAddonsApiRequest!
    private let getElvUIReq: GetElvUIApiRequest!

    init() {
        self.getAllAddonsReq = GetAllAddonsApiRequest(self.session, self.decoder)
        self.getElvUIReq = GetElvUIApiRequest(self.session, self.decoder)
    }
    
    func getAddonsWithCore(_ onComplete: (@escaping ([Addon]) -> Void),
                           _ onError: (@escaping (Error) -> Void)) {
        return self.getElvUI({ (elvui: Addon) in
            self.getAddons({ (addons: [Addon]) in
                var all = Array(addons)
                all.insert(elvui, at: 0)
                onComplete(all)
            }, onError)
        }, onError)
    }
    
    func getElvUI(_ onComplete: (@escaping (Addon) -> Void),
                  _ onError: (@escaping (Error) -> Void)) {
        self.getElvUIReq.call(onComplete, onError)
    }
    
    func getAddons(_ onComplete: (@escaping ([Addon]) -> Void),
                   _ onError: (@escaping (Error) -> Void)) {
        self.getAllAddonsReq.call(onComplete, onError)
    }
}

protocol ApiRequest {
    associatedtype T

    init(_ url: URL!, _ session: URLSession!, _ decoder: JSONDecoder!)
    func deserialize(_: Data) throws -> T
}

internal class ApiRequestBase<T>: ApiRequest {
    private let session: URLSession!
    private let url: URL!
    internal let decoder: JSONDecoder!

    required init(_ url: URL!, _ session: URLSession!, _ decoder: JSONDecoder!) {
        self.session = session
        self.decoder = decoder
        self.url = url
    }

    internal func deserialize(_ data: Data) throws -> T {
        fatalError("deserialize(_:) has not been implemented")
    }

    internal func call(_ onComplete: (@escaping (T) -> Void),
                       _ onError: (@escaping (Error) -> Void)) {
        self.session.dataTask(with: self.url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                return onError(error)
            }

            guard response != nil else {
                return onError(ApiError(message: "No response from server"))
            }

            guard let data = data else {
                return onError(ApiError(message: "Empty server response data"))
            }

            do {
                let result = try self.deserialize(data)
                onComplete(result)
            } catch {
                onError(error)
            }
        }.resume()
    }
}

final class GetAllAddonsApiRequest: ApiRequestBase<[Addon]> {
    init(_ session: URLSession!, _ decoder: JSONDecoder!) {
        super.init(URL(string: "https://www.tukui.org/api.php?addons=all"), session, decoder)
    }
    
    required init(_ url: URL!, _ session: URLSession!, _ decoder: JSONDecoder!) {
        super.init(url, session, decoder)
    }
    
    internal override func deserialize(_ data: Data) throws -> T {
        try self.decoder.decode([Addon].self, from: data)
    }
}

final class GetElvUIApiRequest: ApiRequestBase<Addon> {
    init(_ session: URLSession!, _ decoder: JSONDecoder!) {
        super.init(URL(string: "https://www.tukui.org/api.php?ui=elvui"), session, decoder)
    }
    
    required init(_ url: URL!, _ session: URLSession!, _ decoder: JSONDecoder!) {
        super.init(url, session, decoder)
    }
    
    internal override func deserialize(_ data: Data) throws -> T {
        try self.decoder.decode(Addon.self, from: data)
    }
}
