//
//  Codable+Additions.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//

import Foundation
import Combine

func decode<T: Decodable>(_ data: Data) -> AnyPublisher <T,MEError> {
    let decoder = JSONDecoder()
    return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError{ error in
            .decodingError()
        }
        .eraseToAnyPublisher()
    
}
