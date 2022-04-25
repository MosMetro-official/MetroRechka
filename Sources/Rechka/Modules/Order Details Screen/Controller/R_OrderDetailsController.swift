//
//  R_TicketDetailsController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreTableView
import SwiftDate
import SafariServices
import CoreNetwork

internal final class R_OrderDetailsController : UIViewController {
    
    public var orderID: Int? {
        didSet {
            guard let orderID = orderID else { return }
            self.load(with: orderID)
        }
    }
    
    public var order: RiverOrder? {
        didSet {
            guard let order = order else { return }
            self.makeState(for: order)
            if order.operation.status == .booked && order.operation.timeLeftToCancel > 0 {
                self.seconds = order.operation.timeLeftToCancel
            }
            
            
        }
    }
    
    private var timer: Timer?
    private var paymentController: SFSafariViewController?
    private var needToSetTimer = true
    private var isFirstLoad = true
    
    
    private func set(seconds: Int) {
        self.seconds = seconds
    }
    
    private var seconds: Int = 0 {
        didSet {
            guard let order = order else {
                return
            }
            if needToSetTimer {
                self.setTimer()
            }
            
            if seconds > 0 {
                self.makeState(for: order)
            } else {
                self.removeTimer()
            }
            
            
            
        }
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrderUpdate), name: .riverUpdateOrder, object: nil)
    }
    
    
    @objc private func handleSuccessfulPayment() {
        hidePaymentController { [weak self] in
            guard let self = self, let orderID = self.orderID else { return }
            self.load(with: orderID)
            
        }
    }
    
    @objc private func handlePaymentFailure() {
        hidePaymentController {
            // TODO: Показать ошибку
        }
    }
    
    @objc private func handleOrderUpdate() {
        guard let orderID = orderID else {
            return
        }
        self.orderID = orderID
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
    
    private func showPaymentController(with url: String) {
        guard let paymentURL = URL(string: url) else { return }
        self.paymentController = SFSafariViewController(url: paymentURL)
        self.present(self.paymentController!, animated: true, completion: nil)
    }
    
    private func setTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            self.seconds -= 1
        })
        RunLoop.current.add(timer!, forMode: .common)
        
        self.needToSetTimer = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    private func load(with id: Int) {
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        let loadingState = R_OrderDetailsView.ViewState(
            dataState: .loading,
            state: [],
            onClose: onClose
        )
        
      
        self.set(state: loadingState)
        RiverOrder.get(by: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let order):
                self.isFirstLoad = true
                self.order = order
            case .failure(let error):
                var title = "Возникла ошибка при загрузке"
                if case .genericError(let message) = error {
                    title = message
                }
                
                let finalTitle = title
                DispatchQueue.main.async {
                    let onSelect = Command { [weak self] in
                        guard let self = self, let orderID = self.orderID else { return }
                        self.load(with: orderID)
                        
                    }
                    let err = R_OrderDetailsView.ViewState.Error(
                        image: UIImage(systemName: "xmark.octagon") ?? UIImage(),
                        title: finalTitle,
                        action: onSelect,
                        buttonTitle: "Загрузить еще раз",
                        height: UIScreen.main.bounds.height / 2)
                        .toElement()
                    let state = State(model: .init(header: nil, footer: nil), elements: [err])
                    
                    self.nestedView.viewState = .init(dataState: .error, state: [state], onClose: onClose)
                }
                
            }
        }
    }
    
    
    private func showPDF(for ticket: RiverOperationTicket) {
        let controller = PDFDocumentController()
        self.present(controller, animated: true) {
            controller.ticket = ticket
        }
    }
    
    
    private func showRefundCalculation(for ticket: RiverOperationTicket) {
        let controller = R_BlurRefundController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true) {
            controller.ticket = ticket
        }
    }
    
    private func buttonStateForPayed(ticket: RiverOperationTicket) -> TicketDetailCell.Buttons {
        let onRefundAction = Command { [weak self] in
            self?.showRefundCalculation(for: ticket)
        }
        let refunData = TicketDetailCell.Buttons.ButtonData(title: "Вернуть билет", onSelect: onRefundAction)
        
        let onDownloadAction = Command { [weak self] in
            guard let self = self else { return }
            self.showPDF(for: ticket)
        }
        let downloadData = TicketDetailCell.Buttons.ButtonData(title: "Квитанция", onSelect: onDownloadAction)
        
        return .init(onRefund: refunData,
                     onDownload: downloadData,
                     onRefundDetails: nil,
                     info: nil)
    }
    
    private func showRefundDetails(for ticket: RiverOperationTicket) {
        guard let refund = ticket.refund else { return }
        
        let comission = ticket.price - refund.refundPrice
        
        let comissionStr: String = {
            if comission == 0 {
                return "Комиссии нет"
            } else {
                return "Комиссия - \(comission) ₽"
            }
        }()
        var finalMessage = "Возврат составил – \(refund.refundPrice) ₽\n(\(comissionStr))."
        if let date = refund.refundDate {
            finalMessage = "\(finalMessage) Возврат был сделан \(date.toFormat("d MMMM yyyy HH:mm", locale: Locales.russian))"
        }
        
        let alert = UIAlertController(title: "Детали возврата", message: finalMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func buttonStateForReturned(ticket: RiverOperationTicket) -> TicketDetailCell.Buttons {
        let onRefundDetails = Command { [weak self] in
            self?.showRefundDetails(for: ticket)
        }
        let refundDetails = TicketDetailCell.Buttons.ButtonData(title: "Детали возврата", onSelect: onRefundDetails)
        
        let onDownloadAction = Command { [weak self] in
            guard let self = self else { return }
            self.showPDF(for: ticket)
        }
        let downloadData = TicketDetailCell.Buttons.ButtonData(title: "Квитанция", onSelect: onDownloadAction)
        
        return .init(onRefund: nil,
                     onDownload: downloadData,
                     onRefundDetails: refundDetails,
                     info: nil)
    }
    
    private func buttonStateForBooked(ticket: RiverOperationTicket) -> TicketDetailCell.Buttons {
        
        
        return .init(onRefund: nil,
                     onDownload: nil,
                     onRefundDetails: nil,
                     info: .init(title: "Билет забронирован, ожидаем оплаты", onSelect: nil))
    }
    
    
    private func startPayment() {
        guard let order = order else {
            return
        }
        self.showPaymentController(with: order.url)
        
    }
    
    private func makeState(for order: RiverOrder) {
        var resultigState = [State]()
        // Status
        let statusString: String = {
            switch order.operation.status {
            case .success:
                return "Заказ оплачен"
            case .canceled:
                return "Заказ отменен"
            case .booked:
                return "Ожидаем оплату"
            }
        }()
        
        let statusImage: UIImage = {
            switch order.operation.status {
            case .success:
                return UIImage(named: "checkmark", in: .module, compatibleWith: nil) ?? UIImage()
            case .canceled:
                return UIImage(named: "result_error", in: .module, compatibleWith: nil) ?? UIImage()
            case .booked:
                return UIImage(named: "payment_waiting", in: .module, compatibleWith: nil) ?? UIImage()
            }
        }()
        
        let statusColor: UIColor = {
            switch order.operation.status {
            case .success:
                return .green
            case .canceled:
                return .systemRed
            case .booked:
                return .systemOrange
            }
        }()
        
        let statusData = R_OrderDetailsView.ViewState.TicketStatus(
            title: statusString,
            statusImage: statusImage,
            statusColor: statusColor
        ).toElement()
        
        let statusSection = SectionState(header: nil, footer: nil)
        let statusBlock = State(model: statusSection, elements: [statusData])
        resultigState.append(statusBlock)
        
        if order.operation.status == .booked && self.seconds > 0 {
            let onPay = Command { [weak self] in
                self?.startPayment()
            }
            
            let endBookingDate = order.operation.orderDate + seconds.seconds
            let period = endBookingDate - order.operation.orderDate
            guard let minute = period.minute, let seconds = period.second else { return }
            let minuteStr = minute < 10 ? "0\(minute)" : "\(minute)"
            let secondsStr = seconds < 10 ? "0\(seconds)" : "\(seconds)"
            
            let elapsedTime = "\(minuteStr):\(secondsStr)"
            
            let needToPay = R_OrderDetailsView.ViewState.NeedToPay(onPay: onPay,
                                                                   time: elapsedTime,
                                                                   desc: "Осталось времени").toElement()
            let needToPaySection = SectionState(header: nil, footer: nil)
            let needToPayBlock = State(model: needToPaySection, elements: [needToPay])
            resultigState.append(needToPayBlock)
            
        }
        
        // tickets
        var ticketsStates = [State]()
        
        order.operation.tickets.forEach { ticket in
            var resulting = [State]()
            let place: String = {
                switch ticket.place {
                case -1:
                    return "Любое"
                case 0:
                    return "Без места"
                default:
                    return "Место №\(ticket.place)"
                }
            }()
            
            let buttonsData: TicketDetailCell.Buttons = {
                switch ticket.status {
                case .payed:
                    return buttonStateForPayed(ticket: ticket)
                case .booked:
                    return buttonStateForBooked(ticket: ticket)
                case .returned, .returnedByAgent, .returnedByCarrier:
                    return buttonStateForReturned(ticket: ticket)
                }
            }()
            
            let status: String = {
                switch ticket.status {
                    
                case .payed:
                    return "Оплачен"
                case .returned, .returnedByAgent, .returnedByCarrier:
                    return "Возвращен"
                case .booked:
                    return "Забронирован"
                }
            }()
            
            let element = R_OrderDetailsView.ViewState.Ticket(
                price: "\(Int(ticket.price)) ₽",
                place: place,
                number: "\(ticket.id)",
                passenger: "",
                buttons: buttonsData,
                status: status)
                .toElement()
            let section = SectionState(header: nil, footer: nil)
            let ticketState = State(model: section, elements: [element])
            resulting.append(ticketState)
            if !ticket.additionServices.isEmpty {
                var additionElements = [Element]()
                let additionHeader = R_OrderDetailsView.ViewState.TicketTitle(
                    title: "Дополнительные услуги"
                ).toElement()
                
                let additions: [Element] = ticket.additionServices.map { service in
                    return R_OrderDetailsView.ViewState.Addtional(tariffs: "\(service.name) x\(service.count)", price: "\(service.totalPrice) ₽").toElement()
                }
                additionElements.append(additionHeader)
                additionElements.append(contentsOf: additions)
                
                let additionsSection = SectionState(header: nil, footer: nil)
                resulting.append(.init(model: additionsSection, elements: additionElements))
            }
            ticketsStates.append(contentsOf: resulting)
        }
        
        resultigState.append(contentsOf: ticketsStates)
        
        // info
        let title = R_OrderDetailsView.ViewState.TicketTitle(
            title: "Информация:"
        ).toElement()
        
        
        let stackViewBounds = (UIScreen.main.bounds.width - 40 - 32 - 24 - 8) / 2
        let font = Appearance.customFonts[.subhead] ?? UIFont.systemFont(ofSize: 15, weight: .regular)
        
        func height(for text: String) -> CGFloat {
            return text.height(withConstrainedWidth: stackViewBounds, font: font) + 24
        }
        
        let status = R_OrderDetailsView.ViewState.TicketInfo(
            height: height(for: statusString),
            title: "Статус",
            descr: statusString,
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        
        
        let bookDate = R_OrderDetailsView.ViewState.TicketInfo(
            height: height(for: order.operation.orderDate.toFormat("d MMMM yyyy HH:mm")),
            title: "Дата брони",
            descr: order.operation.orderDate.toFormat("d MMMM yyyy HH:mm"),
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        
        let orderNumber = R_OrderDetailsView.ViewState.TicketInfo(
            height: height(for: "\(order.operation.id)"),
            title: "Номер заказа",
            descr: "\(order.operation.id)",
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let additionsPrice = order.operation.tickets.reduce(0) { partialResult, ticket in
            partialResult + ticket.additionServices.reduce(0, { $0 + $1.totalPrice })
        }
        let totalPrice = order.operation.totalPrice + additionsPrice
        let totalPriceData = R_OrderDetailsView.ViewState.TicketInfo(
            height: height(for: "\(totalPrice) ₽"),
            title: "Общая цена",
            descr: "\(totalPrice) ₽",
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let routeName = R_OrderDetailsView.ViewState.TicketInfo(
            height: height(for: "\(order.operation.routeName)"),
            title: "Маршрут",
            descr: "\(order.operation.routeName)",
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let infoBlock = State(model: .init(header: nil, footer: nil), elements: [title,status,bookDate,orderNumber,totalPriceData,routeName])
        
        resultigState.append(infoBlock)
        
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        let state = R_OrderDetailsView.ViewState(dataState: .loaded, state: resultigState, onClose: onClose)
        self.nestedView.viewState = state
        
    }
    
    
    private func set(state: R_OrderDetailsView.ViewState) {
        self.nestedView.viewState = state
    }
    
    
    private func set(order: RiverOrder) {
        isFirstLoad = false
        self.order = order
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nestedView = R_OrderDetailsView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setListeners()
    }
}
