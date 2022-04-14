//
//  R_BookingScreenController.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView
import SwiftDate
import SafariServices
import CoreNetwork


internal final class R_BookingScreenController : UIViewController {
    
    private var timer: Timer?
    private var paymentController: SFSafariViewController?
    
    var onDismiss: (() -> Void)?
    
    var nestedView = R_BookingScreenView(frame: UIScreen.main.bounds)
    
    var model: RiverOrder? {
        didSet {
            guard let model = model else {
                return
            }
            self.seconds = model.operation.timeLeftToCancel
        }
    }
    
    private var seconds: Int = 1200 {
        didSet {
            if needToSetTimer {
                self.setTimer()
            }
            
            if seconds > 0 {
                Task.detached { [weak self] in
                    guard let self = self else { return }
                    let state = await self.makeState()
                    await self.set(state: state)
                }
            } else {
                self.removeTimer()
            }
            
           
            
        }
    }
    
    private var needToSetTimer = true
    
    override func loadView() {
        self.view = nestedView
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setListeners()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    private func removeTimer() {
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        self.timer = nil
        self.needToSetTimer = true
    }
    
    private func setListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSuccessfulPayment), name: .riverPaymentSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePaymentFailure), name: .riverPaymentFailure, object: nil)
    }
    
    
    @objc private func handleSuccessfulPayment() {
        hidePaymentController {
            self.removeTimer()
            self.dismiss(animated: true) { [weak self] in
                self?.onDismiss?()
            }
        }
    }
    
    @objc private func handlePaymentFailure() {
        hidePaymentController {
            // TODO: Показать ошибку
        }
    }
    
    
    private func hidePaymentController(onDismiss: @escaping () -> Void) {
        guard let paymentController = paymentController else {
            return
        }
        paymentController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.paymentController = nil
            onDismiss()
        }
    }
    
    private func setTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            self.seconds -= 1
        })
        RunLoop.current.add(timer!, forMode: .common)
        
        self.needToSetTimer = false
        
        
    }
    
    
    private func set(state: R_BookingScreenView.ViewState) {
        self.nestedView.viewState = state
    }
    
    
    private func showCancelSuccess() {
        self.nestedView.viewState.dataState = .loaded
        let controller = R_CancelBookingController()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        controller.onClose = Command(action: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            
        })
        self.present(controller, animated: true, completion: nil)
    }
    
    
    private func startCancel() {
        guard let model = model else { return }
        self.nestedView.viewState.dataState = .loading
        model.cancelBooking { result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.showCancelSuccess()
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    let onSelect: () -> Void = { [weak self] in
                        guard let self = self else { return }
                        self.nestedView.viewState.dataState = .loaded
                    }
                    
                    let buttonData = R_Toast.Configuration.Button(image: UIImage(systemName: "xmark"), title: nil, onSelect: onSelect)
                    let errorConfig = R_Toast.Configuration.defaultError(text: err.errorTitle, subtitle: nil, buttonType: .imageButton(buttonData))
                    self.nestedView.viewState.dataState = .error(errorConfig)
                }
            }
        }
    }
    
    private func showPaymentController(with url: String) {
        guard let paymentURL = URL(string: url) else { return }
        self.paymentController = SFSafariViewController(url: paymentURL)
        self.present(self.paymentController!, animated: true, completion: nil)
    }
    
    private func makeState() async -> R_BookingScreenView.ViewState {
        let onSelect: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.nestedView.viewState.dataState = .loaded
        }
        
        let buttonData = R_Toast.Configuration.Button(image: UIImage(systemName: "xmark"), title: nil, onSelect: onSelect)
        let errorConfig = R_Toast.Configuration.defaultError(text: "Произошла ошибка", subtitle: nil, buttonType: .imageButton(buttonData))
        
        guard let model = model else {
            return .init(dataState: .error(errorConfig), states: [], totalPrice: "")
        }
        let endBookingDate = model.operation.orderDate + seconds.seconds
        let period = endBookingDate - model.operation.orderDate
        guard let minute = period.minute, let seconds = period.second else { return .init(dataState: .error(errorConfig), states: [], totalPrice: "")}
        let minuteStr = minute < 10 ? "0\(minute)" : "\(minute)"
        let secondsStr = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        
        let elapsedTime = "\(minuteStr):\(secondsStr)"
        var topElements = [Element]()
        
        let titleHeigght = "Билеты забронированы".height(withConstrainedWidth: UIScreen.main.bounds.width - 40, font: Appearance.customFonts[.largeTitle] ?? UIFont.systemFont(ofSize: 30, weight: .bold)) + 20
        let title = R_BookingScreenView.ViewState.Title(
            title: "Билеты забронированы",
            height: titleHeigght
        ).toElement()
        topElements.append(title)
        let timer = R_BookingScreenView.ViewState.Timer(
            timer: elapsedTime,
            descr: "Осталось времени для оплаты"
        ).toElement()
        topElements.append(timer)
        var cancelElements = [Element]()
        let cancel = R_BookingScreenView.ViewState.Cancel(
            title: "Отменить бронирование",
            onSelect: { [weak self] in
                guard let self = self else { return }
                self.startCancel()
            }
        ).toElement()
        cancelElements.append(cancel)
        let topSection = SectionState(header: nil, footer: nil)
        let topState = State(model: topSection, elements: topElements)
        
        let cancelSection = SectionState(header: nil, footer: nil)
        let cancelState = State(model: cancelSection, elements: cancelElements)
        
        let onClose = Command { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        let onPay = Command { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showPaymentController(with: model.url)
            }
        }
        let additionsPrice = model.operation.tickets.reduce(0) { partialResult, ticket in
            partialResult + ticket.additionServices.reduce(0, { $0 + $1.totalPrice })
        }
        let totalPrice = model.operation.totalPrice + additionsPrice
        
        return .init(dataState: .loaded, states: [topState, cancelState], onClose: onClose, onPay: onPay, totalPrice: "\(Int(totalPrice)) ₽")

    }

  
}
