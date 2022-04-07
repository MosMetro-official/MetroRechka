//
//  HistoryController.swift
//  
//
//  Created by Слава Платонов on 29.03.2022.
//

import UIKit
import CoreTableView
import SwiftDate

class HistoryController: UIViewController {
    
    let tickets = [
        Ticket(title: "Круиз Radisson", desc: "15 марта 17:00", price: "1900 ₽"),
        Ticket(title: "Круиз Radisson", desc: "Заказ отменен", price: "1900 ₽"),
        Ticket(title: "Круиз Radisson", desc: "Ожидает оплаты", price: "1900 ₽")
    ]
    
    let nestedView = HistoryView(frame: UIScreen.main.bounds)
    
    
    var model: RechkaHistoryResponse? {
        didSet {
            guard let model = model else {
                return
            }
            self.items.append(contentsOf: model.orders)
        }
    }
    
    private var items: [RechkaShortOrder] = [] {
        didSet {
            Task.detached { [weak self] in
                guard let self = self else { return }
                let state = await self.makeState()
                await self.set(state: state)
            }
        }
    }
    
    private var isLoading = false {
        didSet {
            Task.detached { [weak self] in
                guard let self = self else { return }
                let state = await self.makeState()
                await self.set(state: state)
            }
        }
    }
    private var isNeedToShowLoading = true
    
    override func loadView() {
        super.loadView()
        view = nestedView
        title = "История"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        self.loadHistory(page: 0, size: 5)
        
    }
    
    @MainActor
    private func set(response: RechkaHistoryResponse) {
        self.model = response
        self.isLoading = false
    }
    
    @MainActor
    private func set(state: HistoryView.ViewState) {
        self.nestedView.viewState = state
    }
    
    private func loadHistory(page: Int, size: Int) {
        if isNeedToShowLoading {
            self.nestedView.viewState = .init(state: [], dataState: .loading)
            isNeedToShowLoading = false
        }
        self.isLoading = true
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let orderResponse = try await RechkaShortOrder.getOrders(size: size, page: page)
                try await Task.sleep(nanoseconds: 0_300_000_000)
                await self.set(response: orderResponse)
            } catch {
                print(error)
                // handle error here
            }
        }
    }
    
    
    @MainActor
    private func showDetails(for order: RechkaShortOrder) {
        let orderController = TicketDetailsController()
        self.present(orderController, animated: true) {
            orderController.orderID = order.id
        }
    }
    
    private func makeState() async -> HistoryView.ViewState {
        var states = [State]()
        let dict = Dictionary.init(grouping: items, by: { element -> DateComponents in
            //let date = Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: (element.dateStart))
            let date = Calendar.current.dateComponents([.day, .month, .year], from: (element.createdDate.dateAt(.startOfDay).date))
            return date
        })
        let sorted = dict.sorted(by: { $0.key > $1.key })
        let ordersSections: [State]  = sorted.compactMap { (key, value) in
            if let first = value.first {
                let sortedTrips: [Element] = value.sorted(by: { $0.createdDate > $1.createdDate}).map { order in
                    let onSelect: () -> () = { [weak self] in
                        guard let self = self else { return }
                        self.showDetails(for: order)
                    }
                    
                    let descr: String = {
                        switch order.status {
                        case .success:
                            return order.createdDate.toFormat("d MMMM yyyy HH:mm", locale: Locales.russian)
                        case .canceled:
                            return "Заказ отменен"
                        case .booked:
                            return "Ожидает оплаты"
                        }
                    }()
                    
                    
                    
                    
                    return HistoryView.ViewState.HistoryTicket(
                        title: order.routeName,
                        descr: descr,
                        price: "\(order.totalPrice) ₽",
                        onSelect: onSelect
                        )
                        .toElement()
                    
                }
                let sectionTitle: String = {
                    if first.createdDate.isToday {
                        return "Сегодня"
                    }
                    
                    if first.createdDate.isYesterday {
                        return "Вчера"
                    }
                    
                    if first.createdDate.isTomorrow {
                        return "Завтра"
                    }
                    return first.createdDate.toFormat("d MMMM", locale: Locales.russianRussia)
                    
                }()
                
                let headerData = HistoryView.ViewState.DateHeader(title: sectionTitle)
                let sectionData = SectionState(header: headerData, footer: nil)
                return State(model: sectionData, elements: sortedTrips)
                
            }
            return nil
        }
        states.append(contentsOf: ordersSections)
        guard let model = model else {
            return .init(state: [], dataState: .loading)
        }
        if self.items.count < model.totalElements {
            let onLoad = Command { [weak self] in
                guard let self = self else { return }
                self.loadHistory(page: model.page + 1, size: 5)
            }
            let loadMore = HistoryView.ViewState.LoadMore(onLoad: isLoading ? nil : onLoad).toElement()
            states.append(.init(model: .init(header: nil, footer: nil), elements: [loadMore]))
        }
        

        return .init(state: states, dataState: .loaded)
        
    }
}

extension HistoryController {
    
    struct Ticket {
        let title: String
        let desc: String
        let price: String
    }
}
