//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

/// Holds the token generated by the Apple Pay Component.
public struct ApplePayDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: PaymentMethodType
    
    /// The token generated by the component.
    public let token: String
    
    /// A string, that describes the payment network backing the card.
    public let network: String
    
    /// The user-selected billing address for this transaction.
    public let billingContact: PKContact?
    
    /// The user-selected shipping address for this transaction.
    public let shippingContact: PKContact?

    /// The shipping method that the user chose.
    public let shippingMethod: PKShippingMethod?
    
    /// Initializes the Apple Pay details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Apple Pay payment method.
    ///   - token: The token generated by the component.
    ///   - network: The payment network backing the Apple pay card.
    ///   - billingContact: The user-selected billing address for this transaction.
    ///   - shippingContact: The user-selected shipping address for this transaction.
    ///   - shippingMethod: The shipping method that the user chose.
    public init(paymentMethod: ApplePayPaymentMethod,
                token: String,
                network: String,
                billingContact: PKContact?,
                shippingContact: PKContact?,
                shippingMethod: PKShippingMethod?) {
        self.type = paymentMethod.type
        self.token = token
        self.network = network
        self.billingContact = billingContact
        self.shippingContact = shippingContact
        self.shippingMethod = shippingMethod
    }
    
    // MARK: - Coding
    
    private enum CodingKeys: String, CodingKey {
        case network = "applePayCardNetwork"
        case token = "applePayToken"
        case type
    }
    
}
