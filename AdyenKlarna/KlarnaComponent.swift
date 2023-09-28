//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit
import KlarnaMobileSDK
import AdyenActions

/// A component that handles payment methods that don't need any payment detail to be filled.
public final class KlarnaComponent: KlarnaMobileSDKActionComponent {

    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The ready to submit payment data.
    public var paymentData: String?

    /// The payment method.
    public let paymentMethod: PaymentMethod?

    /// The delegate of the component.
    public weak var delegate: ActionComponentDelegate?

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    public var configuration: Configuration?

    var klarnaPaymentView: KlarnaPaymentView?

    /// Initializes a new instance of `InstantPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - paymentData: The ready to submit payment data.
    ///   - context: The context object for this component.
    public init(paymentMethod: PaymentMethod,
                context: AdyenContext,
                paymentData: PaymentComponentData,
                configuration: BasicComponentConfiguration) {
        self.paymentMethod = paymentMethod
        self.paymentData = nil
        self.context = context
        self.configuration = configuration
    }

    /// Initializes a new instance of `InstantPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - context: The context object for this component.
    ///   - order: The partial order for this payment.
    public init(paymentMethod: PaymentMethod,
                context: AdyenContext,
                order: PartialPaymentOrder?,
                configuration: BasicComponentConfiguration) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.paymentData = nil
        self.configuration = configuration
    }


    public init(context: Adyen.AdyenContext) {
        self.context = context
        self.paymentMethod = nil
        self.paymentData = nil
        self.configuration = nil
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        //submit(data: paymentData)
    }

    public func handle(_ action: KlarnaMobileSDKAction) {
        self.paymentData = action.paymentData
        let viewController = AdyenKlarnaPaymentViewController(token: action.sdkData.clientToken, category: action.sdkData.category)
        viewController.delegate = self
        if let presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent)
        } else {
            let message = "PresentationDelegate is nil. Provide a presentation delegate to AwaitComponent."
            AdyenAssertion.assertionFailure(message: message)
        }
    }

}


@_spi(AdyenInternal)
extension KlarnaComponent: TrackableComponent {
    public func sendTelemetryEvent() {

    }

    public func didCancel() {

    }
}

extension KlarnaComponent: AdyenKlarnaPaymentProtocol {
    func approved(authToken: String) {
        let additionalDetails = KlarnaActionDetails(authorizationToken: authToken)
        let actionData = ActionComponentData(details: additionalDetails, paymentData: self.paymentData!)
        delegate?.didProvide(actionData, from: self)
    }

    func error(_ error: Error, name: String, message: String, isFatal: Bool) {

        
        delegate?.didFail(with: error, from: self)
    }
}

