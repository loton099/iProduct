//
//  Networkmanager.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//

import Foundation
import Combine

protocol NetworkFetchable {
    func getProductDetails() -> AnyPublisher<[Product],MEError>
}


class NetworkFetcher {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetworkFetcher: NetworkFetchable {
    func getProductDetails() -> AnyPublisher<[Product],MEError> {
        return performNetworkCall(with: makeJsonPlaceholderComponents())
    }
    
    private func performNetworkCall<T: Decodable>(with components: URLComponents) -> AnyPublisher<T,MEError>  {
        
        guard let url = components.url  else {
            let error = MEError.unknownError()
            return Fail(error: error).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError {  error in
                MEError.decodingError()
            }
            .map(\.data)
            .flatMap { data in
                decode(data)
            }
            .eraseToAnyPublisher()
    }
    
}



// MARK: - JsonPlaceHolder  API
private extension NetworkFetcher {

    struct JsonPlaceHolderAPI {
        static let scheme = "https"
        static let host = "60d2fa72858b410017b2ea05.mockapi.io"
        static let path = "/api/v1/menu"
    }
    
    func makeJsonPlaceholderComponents()-> URLComponents {
        var components = URLComponents()
        components.scheme = JsonPlaceHolderAPI.scheme
        components.host = JsonPlaceHolderAPI.host
        components.path = JsonPlaceHolderAPI.path
        return components
    }
    
}
