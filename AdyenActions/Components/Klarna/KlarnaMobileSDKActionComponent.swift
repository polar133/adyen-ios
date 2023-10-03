//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

public protocol KlarnaMobileSDKActionComponent: ActionComponent,
                                                Cancellable {
    /// Initializer that takes an `APIContext`.
    init(context: AdyenContext, configuration: AdyenActionComponent.Configuration.Klarna)

    /// Delegates `PresentableComponent`'s presentation.
    var presentationDelegate: PresentationDelegate? { get set }

    /// Handles an action object.
    /// - Parameters:
    ///   - action: The action object.
    func handle(_ action: KlarnaMobileSDKAction)

}
