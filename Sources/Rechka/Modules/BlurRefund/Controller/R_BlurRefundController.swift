//
//  R_BlurRefundController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreNetwork

internal final class R_BlurRefundController : UIViewController {
    
    
    public var ticket: RiverOperationTicket? {
        didSet {
            guard let ticket = ticket else { return }
            self.startLoad(for: ticket)
        }
    }
    
    private func startLoad(for ticket: RiverOperationTicket) {
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let refund = try await ticket.calculateRefund()
                try await Task.sleep(nanoseconds: 0_300_000_000)
                await MainActor.run { [weak self] in
                    self?.refund = refund
                }
            } catch {
                await MainActor.run {
                    self.handle(error: error)
                }
            }
        }
    }
    
    @MainActor
    private func handle(error: Error) {

        let controller = R_BlurResultController()
        let statusData = R_BlurResultModel.StatusData(title: "Что-то пошло не так", subtitle: error.localizedDescription)
       
        
        let errorModel: R_BlurResultModel = .failure(statusData)
       
        controller.model = errorModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @MainActor
    private func handleSuccessRefund() {

        let controller = R_BlurResultController()
        let statusData = R_BlurResultModel.StatusData(title: "Успешно", subtitle: "Средства будут зачислены обратно на вашу карту в течение нескольких дней")
       
        
        let errorModel: R_BlurResultModel = .success(statusData)
       
        controller.model = errorModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private var refund: RiverTicketRefund? {
        didSet {
            guard let refund = refund, let ticket = ticket else { return }
            print(refund)
            print("dass")
            Task.detached { [weak self] in
                guard let self = self else { return}
                await self.makeState(for: refund, ticket: ticket)
                
            }
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
        self.nestedView.viewState = .loading(.init(title: "Вовзращаем билет", descr: "Немного подождите"))
        guard let ticket = ticket else { return }
        Task.detached { [weak self] in
            do  {
                try await ticket.confirmRefund()
                await self?.handleSuccessRefund()
            } catch {
                await self?.handle(error: error)
            }
            
        }
    }
    
    private func makeState(for refund: RiverTicketRefund, ticket: RiverOperationTicket) async {
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            
        }
        
        let onSubmit = Command { [weak self] in
            guard let self = self else { return }
            self.startRefundConfirm()
            
        
        }
        
        let refundAmount = "Вам вернется \(refund.refundPrice) ₽"
        
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
        await MainActor.run {
            self.nestedView.viewState = .loaded(state)
        }
    }
    
//    private func makeState() async -> BlurRefundView.ViewState {
//        
//        
//        
//    }
    
}