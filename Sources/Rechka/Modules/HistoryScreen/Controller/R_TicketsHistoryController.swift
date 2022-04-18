//
//  R_TicketsHistoryController.swift
//  
//
//  Created by Слава Платонов on 29.03.2022.
//

import UIKit
import CoreTableView
import SwiftDate

internal final class R_TicketsHistoryController: UIViewController {
    
    let nestedView = R_TicketsHistoryView(frame: UIScreen.main.bounds)
    
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
            self.makeState()
        }
    }
    
    private var isLoading = false {
        didSet {
            self.makeState()
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
    
    private func set(response: RechkaHistoryResponse) {
        self.model = response
        self.isLoading = false
    }
    
    private func set(state: R_TicketsHistoryView.ViewState) {
        self.nestedView.viewState = state
    }
    
    private func loadHistory(page: Int, size: Int) {
        if isNeedToShowLoading {
            self.nestedView.viewState = .init(state: [], dataState: .loading)
            isNeedToShowLoading = false
        }
        self.isLoading = true
        RechkaShortOrder.getOrders(size: size, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let ordersResponse):
                self.isLoading = false
                self.model = ordersResponse
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func showDetails(for order: RechkaShortOrder) {
        let orderController = R_OrderDetailsController()
        self.present(orderController, animated: true) {
            orderController.orderID = order.id
        }
    }
    
    private func makeState() {
        let queue = DispatchQueue(label: "river.state.orders", qos: .userInitiated)
        queue.async { [weak self] in
            guard let self = self else { return }
            var states = [State]()
            let dict = Dictionary.init(grouping: self.items, by: { element -> DateComponents in
                //let date = Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: (element.dateStart))
                let date = Calendar.current.dateComponents([.day, .month, .year], from: (element.createdDate.dateAt(.startOfDay).date))
                return date
            })
            let sorted = dict.sorted(by: { $0.key > $1.key })
            let ordersSections: [State] = sorted.compactMap { (key, value) in
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
                        return R_TicketsHistoryView.ViewState.HistoryTicket(
                            title: order.routeName,
                            descr: descr,
                            price: "\(order.totalPrice) ₽",
                            onSelect: onSelect
                        ).toElement()
            
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
                    
                    let headerData = R_TicketsHistoryView.ViewState.DateHeader(title: sectionTitle)
                    let sectionData = SectionState(header: headerData, footer: nil)
                    return State(model: sectionData, elements: sortedTrips)
                }
                return nil
            }
            states.append(contentsOf: ordersSections)
            guard let model = self.model else {
                return
            }
            if self.items.count < model.totalElements {
                let onLoad = Command { [weak self] in
                    guard let self = self else { return }
                    self.loadHistory(page: model.page + 1, size: 5)
                }
                let loadMore = R_TicketsHistoryView.ViewState.LoadMore(onLoad: self.isLoading ? nil : onLoad).toElement()
                states.append(.init(model: .init(header: nil, footer: nil), elements: [loadMore]))
            }
            DispatchQueue.main.async {
                self.nestedView.viewState = .init(state: states, dataState: .loaded)
            }
        }
    }
}
