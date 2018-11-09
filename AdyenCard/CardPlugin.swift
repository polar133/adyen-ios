//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

internal final class CardPlugin: Plugin {
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal weak static var cardScanDelegate: CardScanDelegate?
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
    
}

// MARK: - PaymentDetailsPlugin

extension CardPlugin: PaymentDetailsPlugin {
    
    internal var showsDisclosureIndicator: Bool {
        return true
    }
    
    internal func present(_ details: [PaymentDetail], using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) {
        let amount = paymentSession.payment.amount(for: paymentMethod)
        
        let formViewController = CardFormViewController(appearance: appearance)
        formViewController.title = paymentMethod.name
        formViewController.paymentMethod = paymentMethod
        formViewController.paymentSession = paymentSession
        formViewController.payActionTitle = appearance.checkoutButtonAttributes.title(for: amount)
        
        if let surcharge = paymentMethod.surcharge, let amountString = AmountFormatter.formatted(amount: surcharge.total, currencyCode: amount.currencyCode) {
            formViewController.payActionSubtitle = ADYLocalizedString("surcharge.formatted", amountString)
        }
        
        if let delegate = CardPlugin.cardScanDelegate, delegate.isCardScanEnabled(for: paymentMethod) {
            formViewController.cardScanButtonHandler = { completion in
                delegate.scanCard(for: self.paymentMethod, completion: completion)
            }
        }
        
        formViewController.cardDetailsHandler = { cardInputData in
            var details = details
            details.encryptedCardNumber?.value = cardInputData.encryptedCard.number
            details.encryptedSecurityCode?.value = cardInputData.encryptedCard.securityCode
            details.encryptedExpiryYear?.value = cardInputData.encryptedCard.expiryYear
            details.encryptedExpiryMonth?.value = cardInputData.encryptedCard.expiryMonth
            details.installments?.value = cardInputData.installments
            details.storeDetails?.value = cardInputData.storeDetails.stringValue()
            details.cardholderName?.value = cardInputData.holderName
            
            completion(details)
        }
        
        navigationController.pushViewController(formViewController, animated: true)
    }
    
}
