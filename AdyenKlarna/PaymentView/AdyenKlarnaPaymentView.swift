//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import KlarnaMobileSDK


class AdyenKlarnaPaymentView: UIView {


}

extension AdyenKlarnaPaymentView: KlarnaPaymentEventListener {

    func klarnaInitialized(paymentView: KlarnaPaymentView) {
        paymentView.load()

    }

    func klarnaLoaded(paymentView: KlarnaPaymentView) {
        paymentView.authorize()

    }

    func klarnaLoadedPaymentReview(paymentView: KlarnaPaymentView) {

    }

    func klarnaAuthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?, finalizeRequired: Bool) {

    }

    func klarnaReauthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {

    }

    func klarnaFinalized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {

    }

    func klarnaResized(paymentView: KlarnaPaymentView, to newHeight: CGFloat) {
        updateViewHeight()

    }

    func klarnaFailed(inPaymentView paymentView: KlarnaPaymentView, withError error: KlarnaPaymentError) {

    }

    private func updateViewHeight() {

    }
}
