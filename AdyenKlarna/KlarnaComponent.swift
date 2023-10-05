//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit
import KlarnaMobileSDK
import AdyenActions

public final class KlarnaComponent: KlarnaMobileSDKActionComponent {

    public typealias Configuration = AdyenActionComponent.Configuration.Klarna

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    public var configuration: Configuration?

    /// The ready to submit payment data.
    public var paymentData: String?

    /// The delegate of the component.
    public weak var delegate: ActionComponentDelegate?

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    private var klarnaPaymentView: KlarnaPaymentView?

    /// Initializes a new instance of `KlarnaComponent`.
    ///
    /// - Parameters:
    ///   - context: The context object for this component.
    ///   - configuration: Klarna configuration.
    public init(context: Adyen.AdyenContext,
                configuration: AdyenActionComponent.Configuration.Klarna) {
        self.context = context
        self.configuration = configuration
    }

    public func handle(_ action: KlarnaMobileSDKAction) {
        self.paymentData = action.paymentData
        let viewController = AdyenKlarnaPaymentViewController(token: action.sdkData.clientToken,
                                                              category: action.sdkData.category,
                                                              url: configuration!.returnURL!)
        viewController.delegate = self
        if let presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent)
        } else {
            let message = "PresentationDelegate is nil. Provide a presentation delegate to KlarnaComponent."
            AdyenAssertion.assertionFailure(message: message)
        }
    }

}

@_spi(AdyenInternal)
extension KlarnaComponent: TrackableComponent {
    public func sendTelemetryEvent() {
        let flavor: TelemetryFlavor = _isDropIn ? .dropInComponent : .components(type: .klarna)
        context.analyticsProvider.sendTelemetryEvent(flavor: flavor)
    }

    public func didCancel() { }
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

