//
//  String+Additions.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//

import Foundation
import CommonCrypto

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    func localized(withComment comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
