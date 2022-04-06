//
//  R_TicketsHistoryController.swift
//  
//
//  Created by Слава Платонов on 29.03.2022.
//

import UIKit
import CoreTableView

internal final class R_TicketsHistoryController: UIViewController {
    
    let tickets = [
        Ticket(title: "Круиз Radisson", desc: "15 марта 17:00", price: "1900 ₽"),
        Ticket(title: "Круиз Radisson", desc: "Заказ отменен", price: "1900 ₽"),
        Ticket(title: "Круиз Radisson", desc: "Ожидает оплаты", price: "1900 ₽")
    ]
    
    let nestedView = R_TicketsHistoryView(frame: UIScreen.main.bounds)
    
    override func loadView() {
        super.loadView()
        view = nestedView
        title = "История"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeState()
    }
    
    private func makeState() {
        var states = [State]()
        for ticket in tickets {
            let ticketRow = R_TicketsHistoryView.ViewState.HistoryTicket(
                title: ticket.title,
                descr: ticket.desc,
                price: ticket.price,
                onSelect: {
                    #warning("OPEN_TICKET_HERE")
                }
            ).toElement()
            let ticketSec = SectionState(header: nil, footer: nil)
            let ticketState = State(model: ticketSec, elements: [ticketRow])
            states.append(ticketState)
        }
        nestedView.viewState = R_TicketsHistoryView.ViewState(state: states, dataState: .loaded)
    }
}

extension R_TicketsHistoryController {
    
    struct Ticket {
        let title: String
        let desc: String
        let price: String
    }
}
