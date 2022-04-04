//
//  BookingController.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView
import SwiftDate
import SafariServices


final class BookingController : UIViewController {
    
    private var timer: Timer?
    private var paymentController: SFSafariViewController?
    
    var onDismiss: (() -> Void)?
    
    var nestedView = BookingView(frame: UIScreen.main.bounds)
    
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
            Task.detached { [weak self] in
                guard let self = self else { return }
                let state = await self.makeState()
                await self.set(state: state)
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
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        self.timer = nil
    }
    
    private func setListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSuccessfulPayment), name: .riverPaymentSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePaymentFailure), name: .riverPaymentFailure, object: nil)
    }
    
    
    @objc private func handleSuccessfulPayment() {
        hidePaymentController {
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
        RunLoop.current.add(timer!, forMode: .default)
        
        self.needToSetTimer = false
        
        
    }
    
    @MainActor
    private func set(state: BookingView.ViewState) {
        self.nestedView.viewState = state
    }
    
    private func showPaymentController(with url: String) {
        guard let paymentURL = URL(string: url) else { return }
        self.paymentController = SFSafariViewController(url: paymentURL)
        self.present(self.paymentController!, animated: true, completion: nil)
    }
    
    private func makeState() async -> BookingView.ViewState {
        guard let model = model else {
            return .init(dataState: .error, states: [], totalPrice: "")
        }
        let endBookingDate = model.operation.orderDate + seconds.seconds
        let period = endBookingDate - model.operation.orderDate
        guard let minute = period.minute, let seconds = period.second else { return .init(dataState: .error, states: [], totalPrice: "")}
        let elapsedTime = "\(minute):\(seconds)"
        var topElements = [Element]()
        let title = BookingView.ViewState.Title(
            title: "Билеты забронированы"
        ).toElement()
        topElements.append(title)
        let timer = BookingView.ViewState.Timer(
            timer: elapsedTime,
            descr: "Осталось времени для оплаты"
        ).toElement()
        topElements.append(timer)
        var cancelElements = [Element]()
        let cancel = BookingView.ViewState.Cancel(
            title: "Отменить бронирование",
            onSelect: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let controller = CancelBookingController()
                    controller.modalTransitionStyle = .crossDissolve
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
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
        
        return .init(dataState: .loaded, states: [topState, cancelState], onClose: onClose, onPay: onPay, totalPrice: "\(Int(model.operation.totalPrice)) ₽")

    }

  
}
