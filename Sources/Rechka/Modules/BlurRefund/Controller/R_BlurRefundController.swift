//
//  R_BlurRefundController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import MMCoreNetworkCallbacks
import CoreTableView

internal final class R_BlurRefundController : UIViewController {
    
    public var ticket: RiverOperationTicket? {
        didSet {
            guard let ticket = ticket else { return }
            self.startLoad(for: ticket)
        }
    }
    
    private func startLoad(for ticket: RiverOperationTicket) {
        ticket.calculateRefund { [weak self] result in
            switch result {
            case .success(let refund):
                self?.refund = refund
            case .failure(let error):
                self?.handle(error: error)
            }
        }
    }
    
    
    private func handle(error: APIError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let controller = R_BlurResultController()
            let statusData = R_BlurResultModel.StatusData(title: "Что-то пошло не так", subtitle: error.localizedDescription)
           
            
            let errorModel: R_BlurResultModel = .failure(statusData)
           
            controller.model = errorModel
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    private func handleSuccessRefund() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let controller = R_BlurResultController()
            let statusData = R_BlurResultModel.StatusData(title: "Успешно", subtitle: "Средства будут зачислены обратно на вашу карту в течение нескольких дней")
           
            
            let successModel: R_BlurResultModel = .success(statusData)
           
            controller.model = successModel
            self.navigationController?.pushViewController(controller, animated: true)
            NotificationCenter.default.post(name: .riverUpdateOrder, object: nil)
        }
        
    }
    
    private var refund: RiverTicketRefund? {
        didSet {
            guard let refund = refund, let ticket = ticket else { return }
            self.makeState(for: refund, ticket: ticket)
        }
    }
    
    private let nestedView = R_BlurRefundView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nestedView.viewState = .loading(.init(title: "Считаем сумму возврата", descr: "Немного подождите"))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension R_BlurRefundController {
    
    private func startRefundConfirm() {
        self.nestedView.viewState = .loading(.init(title: "Возвращаем билет", descr: "Немного подождите"))
        guard let ticket = ticket else { return }
        ticket.confirmRefund { [weak self] result in
            switch result {
            case .success():
                self?.handleSuccessRefund()
            case .failure(let error):
                self?.handle(error: error)
            }
        }
        
     
    }
    
    private func makeState(for refund: RiverTicketRefund, ticket: RiverOperationTicket) {
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let onSubmit = Command { [weak self] in
            guard let self = self else { return }
            self.startRefundConfirm()
        }
        
        var refundAmount = "Вам вернется \(refund.refundPrice) ₽ за билет"
        if !refund.additionRefunds.isEmpty {
            let totalAdditionRefund = refund.additionRefunds.reduce(0, { $0 + $1.priceTotalRefund })
            let additionsStr = refund.additionRefunds.map { "\($0.name) x\($0.count)" }.joined(separator: ",")
            refundAmount = "\(refundAmount) и \(totalAdditionRefund) ₽ за дополнительные услуги: \(additionsStr)"
        }
        let comission = ticket.price - refund.refundPrice
        let comissionStr: String = {
            if comission == 0 {
                return "Комиссии нет"
            } else {
                return "Комиссия - \(comission) ₽"
            }
        }()
        let state = R_BlurRefundView.ViewState.LoadedState(refunAmount: refundAmount,
                                                         comission: comissionStr,
                                                         onSubmit: onSubmit,
                                                         onClose: onClose)
        self.nestedView.viewState = .loaded(state)
    }
    
//    private func makeState() async -> BlurRefundView.ViewState {
//        
//        
//        
//    }
    
}
