//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public final class KlarnaMobileSDKAction: Decodable {

    /// KlarnaMobileSDK specific data.
    public let sdkData: KlarnaMobileSDKData

    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String

}

public struct KlarnaMobileSDKData: Decodable {

    /// Token that was returned when the session is created.
    public let clientToken: String

    /// The payment method category that should be rendered in the view.
    public let category: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clientToken = try container.decode(String.self, forKey: .clientToken)
        category = try container.decode(String.self, forKey: .category)
    }

    private enum CodingKeys: String, CodingKey {
        case clientToken = "client_token"
        case category = "payment_method_category"
    }

}
