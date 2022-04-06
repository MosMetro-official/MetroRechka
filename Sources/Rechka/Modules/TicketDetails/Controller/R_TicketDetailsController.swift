//
//  R_TicketDetailsController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreTableView
import SwiftDate

internal final class R_TicketDetailsController : UIViewController {
    
    public var orderID: Int? {
        didSet {
            guard let orderID = orderID else { return }
            self.load(with: orderID)
        }
    }
    
    public var order: RiverOrder? {
        didSet {
            guard let order = order else { return }
            Task.detached { [weak self] in
                guard let self = self else { return }
                let state = await self.makeState(for: order)
                await self.set(state: state)
            }
        }
    }
    
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
      
    private func load(with id: Int) {
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        let loadingState = R_TicketsDetailsView.ViewState(
            dataState: .loading,
            state: [],
            onClose: onClose
        )
        Task.detached { [weak self] in
            guard let self = self else { return }
            await self.set(state: loadingState)
            do {
                let order = try await RiverOrder.get(by: id)
                await self.set(order: order)
            } catch {
                
            }
        }
    }
    
    private func makeState(for order: RiverOrder) async -> R_TicketsDetailsView.ViewState {
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
        
        let statusData = R_TicketsDetailsView.ViewState.TicketStatus(
            title: statusString,
            statusImage: statusImage,
            statusColor: statusColor
        ).toElement()
        
        let statusSection = SectionState(header: nil, footer: nil)
        let statusBlock = State(model: statusSection, elements: [statusData])
        resultigState.append(statusBlock)
        
        // tickets
        let tickets: [State] = order.operation.tickets.map { ticket in
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
            
            let element = R_TicketsDetailsView.ViewState.Ticket(
                price: "\(Int(ticket.price)) ₽",
                place: place,
                number: "\(ticket.id)",
                passenger: "",
                onRefund: nil,
                onDownload: nil,
                downloadTitle: "some",
                onRefundDetails: nil
            ).toElement()
            let section = SectionState(header: nil, footer: nil)
            return .init(model: section, elements: [element])
        }
        
        resultigState.append(contentsOf: tickets)
        
        // info
        let title = R_TicketsDetailsView.ViewState.TicketTitle(
            title: "Информэйшон:"
        ).toElement()
        
        let status = R_TicketsDetailsView.ViewState.TicketInfo(
            title: "Статус",
            descr: statusString,
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let bookDate = R_TicketsDetailsView.ViewState.TicketInfo(
            title: "Дата брони",
            descr: order.operation.orderDate.toFormat("d MMMM yyyy HH:mm"),
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let orderNumber = R_TicketsDetailsView.ViewState.TicketInfo(
            title: "Номер заказа",
            descr: "\(order.operation.id)",
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let totalPrice = R_TicketsDetailsView.ViewState.TicketInfo(
            title: "Общая цена",
            descr: "\(order.operation.totalPrice) ₽",
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let routeName = R_TicketsDetailsView.ViewState.TicketInfo(
            title: "Маршрут",
            descr: "\(order.operation.routeName)",
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        
        let infoBlock = State(model: .init(header: nil, footer: nil), elements: [title,status,bookDate,orderNumber,totalPrice,routeName])
        
        resultigState.append(infoBlock)
        
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        return .init(dataState: .loaded, state: resultigState, onClose: onClose)
        
    }
    
    @MainActor
    private func set(state: R_TicketsDetailsView.ViewState) {
        self.nestedView.viewState = state
    }
    
    @MainActor
    private func set(order: RiverOrder) {
        self.order = order
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nestedView = R_TicketsDetailsView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
    
//    private func makeDummyState() {
//        let status = TicketsDetailsView.ViewState.TicketStatus(
//            title: "Qwerty",
//            status: .waitnig
//        ).toElement()
//        let model0 = SectionState(header: nil, footer: nil)
//        let block0 = State(model: model0, elements: [status])
//        let ticket1 = TicketsDetailsView.ViewState.Ticket(
//            price: "100500 $",
//            place: "в жопе мира",
//            number: "13 слева",
//            passenger: "Николаус",
//            onRefund: { [weak self] in
//                guard let self = self else { return }
//                self.onRefundSelect()
//            },
//            onDownload: { [weak self] in
//                guard let self = self else { return }
//                self.onDownloadSelect()
//            },
//            downloadTitle: "Квитошка",
//            onRefundDetails: { [weak self] in
//                guard let self = self else { return }
//                self.onRefundDetailsSelect()
//            }
//        ).toElement()
//        let model1 = SectionState(header: nil, footer: nil)
//        let block1 = State(model: model1, elements: [ticket1])
//        let ticket2 = TicketsDetailsView.ViewState.Ticket(
//            price: "100500 $",
//            place: "в жопе мира",
//            number: "13 слева",
//            passenger: "Николаус",
//            onRefund: { [weak self] in
//                guard let self = self else { return }
//                self.onRefundSelect()
//            },
//            onDownload: { [weak self] in
//                guard let self = self else { return }
//                self.onDownloadSelect()
//            },
//            downloadTitle: "Квитошка",
//            onRefundDetails: { [weak self] in
//                guard let self = self else { return }
//                self.onRefundDetailsSelect()
//            }
//        ).toElement()
//        let model2 = SectionState(header: nil, footer: nil)
//        let block2 = State(model: model2, elements: [ticket2])
//
//        let title = TicketsDetailsView.ViewState.TicketTitle(
//            title: "Информэйшон:"
//        ).toElement()
//        let info0 = TicketsDetailsView.ViewState.TicketInfo(
//            title: "Мой статус",
//            descr: "Интересный",
//            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
//        ).toElement()
//        let model3 = SectionState(header: nil, footer: nil)
//        let block3 = State(model: model3, elements: [title, info0])
//
//        self.nestedView.configure(with: [block0, block1, block2, block3])
//    }
    
    private func onRefundSelect() {
        print(#function)
    }
    
    private func onDownloadSelect() {
        print(#function)
    }
    
    private func onRefundDetailsSelect() {
        print(#function)
    }
}
