//
//  HistoryController.swift
//  
//
//  Created by Слава Платонов on 29.03.2022.
//

import UIKit
import CoreTableView

class HistoryController: UIViewController {
    
    let tickets = [
        Ticket(title: "Круиз Radisson", desc: "15 марта 17:00", price: "1900 ₽"),
        Ticket(title: "Круиз Radisson", desc: "Заказ отменен", price: "1900 ₽"),
        Ticket(title: "Круиз Radisson", desc: "Ожидает оплаты", price: "1900 ₽")
    ]
    
    let nestedView = HistoryView(frame: UIScreen.main.bounds)
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeState()
        title = "История"
    }
    
    private func makeState() {
        var ticketStates: [State] = []
        for ticket in tickets {
            let ticketRow = HistoryView.ViewState.HistoryTicket(title: ticket.title, description: ticket.desc, price: ticket.price, onSelect: {
                // open ticket
            }, height: 60).toElement()
            let ticketSec = SectionState(header: nil, footer: nil)
            let ticketState = State(model: ticketSec, elements: [ticketRow])
            ticketStates.append(ticketState)
        }
        
        nestedView.viewState = HistoryView.ViewState(state: ticketStates, dataState: .loaded)
    }
}

extension HistoryController {
    struct Ticket {
        let title: String
        let desc: String
        let price: String
    }
}
