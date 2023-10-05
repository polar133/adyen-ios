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
    func error(_ error: Error, name: String, message: String, isFatal: Bool)
}

final class AdyenKlarnaPaymentViewController: UIViewController {

    private lazy var containerView = UIStackView(frame: .zero)
    var klarnaPaymentView: KlarnaPaymentView?
    var paymentViewHeightConstraint: NSLayoutConstraint?

    var clientToken: String
    var paymentCategory: String
    var returnURL: URL

    let padding = 12.0

    weak var delegate: AdyenKlarnaPaymentProtocol?

    internal init(token: String, category: String, url: URL) {
        clientToken = token
        paymentCategory = category
        returnURL = url
        super.init(nibName: nil,
                   bundle: Bundle(for: AdyenKlarnaPaymentViewController.self))
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupView()
    }

    override public var preferredContentSize: CGSize {
        get { CGSize(width: self.view.adyen.minimalSize.width, height:  UIScreen.main.bounds.height) }
        set { super.preferredContentSize = newValue }
    }

    func setupView() {
        containerView.axis = .vertical
        containerView.spacing = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)

        containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding).isActive = true
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding).isActive = true
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: padding).isActive = true

        setupPaymentView(in: containerView)
        setupAuthorizeButton(in: containerView)

    }

    func setupPaymentView(in view: UIStackView) {

        klarnaPaymentView = KlarnaPaymentView(category: self.paymentCategory, returnUrl: returnURL, eventListener: self)
        klarnaPaymentView?.loggingLevel = .error

        klarnaPaymentView?.translatesAutoresizingMaskIntoConstraints = false

        if klarnaPaymentView != nil {
            view.addArrangedSubview(klarnaPaymentView!)
            self.klarnaPaymentView!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            self.klarnaPaymentView!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            self.paymentViewHeightConstraint = klarnaPaymentView!.heightAnchor.constraint(equalToConstant: 0)
            self.paymentViewHeightConstraint?.isActive = true
        }

        klarnaPaymentView?.initialize(clientToken: clientToken)
    }

    func setupAuthorizeButton(in view: UIStackView) {

        let authBtn = UIButton()
        authBtn.translatesAutoresizingMaskIntoConstraints = false
        authBtn.setTitle("Continue", for: .normal)
        authBtn.backgroundColor = .black
        authBtn.setTitleColor(UIColor.white, for: .normal)
        authBtn.addTarget(self, action: #selector(authorizePressed), for: .touchUpInside)
        view.addArrangedSubview(authBtn)

        authBtn.layer.cornerRadius = 8

        authBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        authBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        view.trailingAnchor.constraint(equalTo: authBtn.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: authBtn.bottomAnchor).isActive = true
    }

    @IBAction func authorizePressed() {
        klarnaPaymentView?.authorize()
    }

}

extension AdyenKlarnaPaymentViewController: KlarnaPaymentEventListener {

    func klarnaInitialized(paymentView: KlarnaPaymentView) {
        paymentView.load()
    }

    func klarnaLoaded(paymentView: KlarnaPaymentView) { }

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
        self.delegate?.error(error, name: error.name, message: error.message, isFatal: error.isFatal)
    }
}
