//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view controller that allows looking up of addresses via a search term
/// and also allows manual input of an address
@_spi(AdyenInternal)
public class AddressLookupViewController: UINavigationController, AdyenObserver {
    
    internal private(set) var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        updateInterface(for: viewModel.interfaceState)
        observe(viewModel.$interfaceState) { [weak self] interfaceState in
            self?.updateInterface(for: interfaceState)
        }
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Controller Factory

private extension AddressLookupViewController {
    
    private func buildSearchViewController() -> SearchViewController {
        
        AddressLookupSearchViewController(
            style: viewModel.style.search,
            localizationParameters: viewModel.localizationParameters,
            delegate: self
        )
    }
    
    private func buildFormViewController(prefillAddress: PostalAddress?) -> AddressInputFormViewController {
        
        AddressInputFormViewController(
            viewModel: viewModel.addressInputFormViewModel(with: prefillAddress)
        )
    }
}

// MARK: - Delegate Conformances

extension AddressLookupViewController: AddressLookupSearchDelegate {
    
    internal func addressLookupSearchSwitchToManualEntry() {
        viewModel.handleSwitchToManualEntryTapped()
    }
    
    internal func addressLookupSearchLookUp(searchTerm: String, resultHandler: @escaping ([ListItem]) -> Void) {
        viewModel.lookUp(searchTerm: searchTerm, resultHandler: resultHandler)
    }
    
    internal func addressLookupSearchCancel() {
        viewModel.handleDismissSearchTapped()
    }
}

// MARK: - Navigation

private extension AddressLookupViewController {
    
    func updateInterface(for interfaceState: AddressLookupViewController.InterfaceState) {
        switch interfaceState {
        case let .form(prefillAddress):
            show(viewController: buildFormViewController(prefillAddress: prefillAddress))
            
        case .search:
            show(viewController: buildSearchViewController())
        }
    }
    
    func show(viewController: UIViewController) {
        UIView.transition(
            with: self.view,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            self.viewControllers = [viewController]
        }
    }
}

private extension AddressLookupViewController.ViewModel {
    
    func addressInputFormViewModel(
        with prefillAddress: PostalAddress?
    ) -> AddressInputFormViewController.ViewModel {
        
        .init(
            style: style.form,
            localizationParameters: localizationParameters,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            supportedCountryCodes: supportedCountryCodes,
            handleShowSearch: handleShowSearchTapped(currentInput:),
            completionHandler: handleAddressInputFormCompletion(validAddress:)
        )
    }
}
