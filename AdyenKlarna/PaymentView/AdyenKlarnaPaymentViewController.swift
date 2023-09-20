//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//
@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit
import KlarnaMobileSDK

protocol AdyenKlarnaPaymentProtocol: AnyObject {
    func approved(authToken: String)
}

final class AdyenKlarnaPaymentViewController: UIViewController {

    private lazy var containerView = UIStackView(frame: .zero)
    var klarnaPaymentView: KlarnaPaymentView?
    var paymentViewHeightConstraint: NSLayoutConstraint?

    var clientToken: String
    var paymentCategory: String

    weak var delegate: AdyenKlarnaPaymentProtocol?

    internal init(token: String, category: String) {
        clientToken = token
        paymentCategory = category
        super.init(nibName: nil,
                   bundle: Bundle(for: AdyenKlarnaPaymentViewController.self))
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if paymentViewHeightConstraint == nil {
            preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        } else {
            preferredContentSize = CGSize(width: containerView.adyen.minimalSize.width,
                                          height: 1000)
        }

    }

    func setupView() {
        containerView.axis = .vertical
        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)

        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)

        //containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        //containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        //containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        //containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        setupPaymentView(in: containerView)

    }

    func setupPaymentView(in view: UIStackView) {
        klarnaPaymentView = KlarnaPaymentView(category: self.paymentCategory, returnUrl: URL(string: "demo-app://")!, eventListener: self)
        klarnaPaymentView?.translatesAutoresizingMaskIntoConstraints = false
        
        if klarnaPaymentView != nil {
            view.addArrangedSubview(klarnaPaymentView!)
            self.paymentViewHeightConstraint = klarnaPaymentView!.heightAnchor.constraint(equalToConstant: 0)
            self.paymentViewHeightConstraint?.isActive = true
        }

        klarnaPaymentView?.initialize(clientToken: self.clientToken)
    }

}

extension AdyenKlarnaPaymentViewController: KlarnaPaymentEventListener {

    func klarnaInitialized(paymentView: KlarnaPaymentView) {
        paymentView.load()

    }

    func klarnaLoaded(paymentView: KlarnaPaymentView) {
        paymentView.authorize()

    }

    func klarnaLoadedPaymentReview(paymentView: KlarnaPaymentView) { }

    func klarnaAuthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?, finalizeRequired: Bool) {

        if approved, authToken != nil {
            self.delegate?.approved(authToken: authToken!)
        }
    }

    func klarnaReauthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) { }

    func klarnaFinalized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) { }

    func klarnaResized(paymentView: KlarnaPaymentView, to newHeight: CGFloat) {
        self.paymentViewHeightConstraint?.constant = newHeight
        self.view.setNeedsLayout()

    }

    func klarnaFailed(inPaymentView paymentView: KlarnaPaymentView, withError error: KlarnaPaymentError) {
        print("error")
    }
}
