//
//  TicketDetailsController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreTableView

final class TicketDetailsController : UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.makeDummyState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nestedView = TicketsDetailsView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
    
    private func makeDummyState() {
        let status = TicketsDetailsView.ViewState.TicketStatus(
            title: "Qwerty",
            status: .waitnig
        ).toElement()
        let model0 = SectionState(header: nil, footer: nil)
        let block0 = State(model: model0, elements: [status])
        let ticket1 = TicketsDetailsView.ViewState.Ticket(
            price: "100500 $",
            place: "в жопе мира",
            number: "13 слева",
            passenger: "Николаус",
            onRefund: { [weak self] in
                guard let self = self else { return }
                self.onRefundSelect()
            },
            onDownload: { [weak self] in
                guard let self = self else { return }
                self.onDownloadSelect()
            },
            downloadTitle: "Квитошка",
            onRefundDetails: { [weak self] in
                guard let self = self else { return }
                self.onRefundDetailsSelect()
            }
        ).toElement()
        let model1 = SectionState(header: nil, footer: nil)
        let block1 = State(model: model1, elements: [ticket1])
        let ticket2 = TicketsDetailsView.ViewState.Ticket(
            price: "100500 $",
            place: "в жопе мира",
            number: "13 слева",
            passenger: "Николаус",
            onRefund: { [weak self] in
                guard let self = self else { return }
                self.onRefundSelect()
            },
            onDownload: { [weak self] in
                guard let self = self else { return }
                self.onDownloadSelect()
            },
            downloadTitle: "Квитошка",
            onRefundDetails: { [weak self] in
                guard let self = self else { return }
                self.onRefundDetailsSelect()
            }
        ).toElement()
        let model2 = SectionState(header: nil, footer: nil)
        let block2 = State(model: model2, elements: [ticket2])
        
        let title = TicketsDetailsView.ViewState.TicketTitle(
            title: "Информэйшон:"
        ).toElement()
        let info0 = TicketsDetailsView.ViewState.TicketInfo(
            title: "Мой статус",
            descr: "Интересный",
            image: UIImage(named: "ticket_info_check", in: .module, compatibleWith: nil)!
        ).toElement()
        let model3 = SectionState(header: nil, footer: nil)
        let block3 = State(model: model3, elements: [title, info0])
        
        self.nestedView.configure(with: [block0, block1, block2, block3])
    }
    
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
