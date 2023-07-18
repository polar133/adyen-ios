//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Holds the results of the 3D Secure 2 component.
public enum ThreeDS2Details: AdditionalDetails {
    
    /// When a fingerprint was taken, this case contains the generated 3D Secure 2 fingerprint.
    case fingerprint(String)
    
    /// When a challenge was perform, this case contains the 3D Secure 2 challenge result.
    case challengeResult(ThreeDSResult)

    /// When a 3DS flow is completed.
    case completed(ThreeDSResult)

    case error(ThreeDSError)
    
    // MARK: - Encoding
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .fingerprint(fingerprint):
            try container.encode(fingerprint, forKey: .fingerprint)
        case let .challengeResult(challengeResult):
            try container.encode(challengeResult.payload, forKey: .challengeResult)
        case let .completed(result):
            try container.encode(result.payload, forKey: .threeDSResult)
        case let .error(threeDSError):
            try container.encode(threeDSError.payload, forKey: .threeDS2SDKError)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case fingerprint = "threeds2.fingerprint"
        case challengeResult = "threeds2.challengeResult"
        case threeDSResult
        case threeDS2SDKError
    }
    
}
