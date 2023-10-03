//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//
@_spi(AdyenInternal) import Adyen
import Foundation

public struct KlarnaActionDetails: AdditionalDetails {

    public let authorizationToken: String

    public init(authorizationToken: String) {
        self.authorizationToken = authorizationToken
    }

    private enum CodingKeys: String, CodingKey {
        case authorizationToken = "authorization_token"
    }

}
