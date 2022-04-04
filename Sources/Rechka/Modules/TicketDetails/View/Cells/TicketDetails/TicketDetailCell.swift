//
//  TicketDetailCell.swift
//  MosmetroNew
//
//  Created by Гусейн on 10.12.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import CoreTableView

protocol _TicketDetail : CellData {
    var price : String { get }
    var place : String { get }
    var number : String { get }
    var passenger : String { get }
    var onRefund : Command<Void>? { get }
    var onDownload : Command<Void>? { get }
    var downloadTitle : String { get }
    var onRefundDetails : Command<Void>? { get }
}

extension _TicketDetail {
    
    var height: CGFloat {
        return 275 // тут проверку на статус надо сделать
    }
    
    func hashValues() -> [Int] {
        return [
            price.hashValue,
            place.hashValue,
            number.hashValue,
            passenger.hashValue,
            downloadTitle.hashValue,
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TicketDetailCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TicketDetailCell.identifire, bundle: .module), forCellReuseIdentifier: TicketDetailCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TicketDetailCell.identifire, for: indexPath) as? TicketDetailCell
        else { return .init() }
        return cell
    }
}

class TicketDetailCell: UITableViewCell {

    private  var onRefund : Command<Void>?
    private  var onDownload : Command<Void>?
    private  var onRefundDetails : Command<Void>?
    
    @IBOutlet private var ticketViewToStatusView: NSLayoutConstraint!
    
    @IBOutlet private var ticketViewToSuperview: NSLayoutConstraint!
    
    @IBOutlet private var ticketView: UIView!
    @IBOutlet private var statusView: UIView!
    @IBOutlet private var statusLabel: UILabel!
    
    @IBOutlet private var needToPayLabel: UILabel!
    @IBOutlet private var refundDetailsButton: UIButton!
    @IBOutlet private var docButton: UIButton!
    @IBOutlet private var returnButton: UIButton!
    
    @IBOutlet private var rightRoundView: UIView!
    @IBOutlet private var leftRoundView: UIView!
    
    @IBOutlet private var ticketNumberLabel: UILabel!
    @IBOutlet private var ticketPriceLabel: UILabel!
    @IBOutlet private var placelabel: UILabel!
    @IBOutlet private var separatorView: UIView!
    
    @IBOutlet private var passengerDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @IBAction func handleRefund(_ sender: UIButton) {
        self.onRefund?.perform(with: ())
    }
    
    
    @IBAction func handleDownload(_ sender: Any) {
        self.onDownload?.perform(with: ())
    }
    
    @IBAction func handleRefundDetails(_ sender: Any) {
        self.onRefundDetails?.perform(with: ())
    }
    
    private func setup() {
        let color : UIColor = UIColor.custom(for: .emptyTicketsLayer)
        returnButton.backgroundColor = .clear
        returnButton.layer.borderWidth = 1
        returnButton.layer.borderColor = color.cgColor

//        returnButton.layer.borderColor = UIColor.custom(for: .emptyTicketsLayer).cgColor
        
        docButton.roundCorners(.all, radius: 8)
        statusView.roundCorners(.top, radius: 12)
        ticketView.roundCorners(.all, radius: 12)
        returnButton.roundCorners(.all, radius: 8)
        leftRoundView.roundCorners(.all, radius: 12)
        rightRoundView.roundCorners(.all, radius: 12)
        refundDetailsButton.roundCorners(.all, radius: 8)
        
        drawDottedLine(start: CGPoint(x: 12, y: 12), end: CGPoint(x: (UIScreen.main.bounds.width - 32 - 12), y: 12), view: separatorView)
    }
    
    // Не стал удалять - потом понадобится =)
    
//    private func handleStatusView(status: BusOrder.BookingStatus) {
//        switch status {
//        case .created, .booked, .error, .fullyReturned, .cancelled, .partiallyReturned, .partiallyCancelled:
//            self.statusLabel.text = status.text()
//            self.statusLabel.textColor = status.ticketTextColor()
//            self.ticketViewToSuperview.priority = .defaultLow
//            self.ticketViewToStatusView.priority = .defaultHigh
//            self.statusView.isHidden = false
//
//        case .paid:
//            self.ticketViewToSuperview.priority = .defaultHigh
//            self.ticketViewToStatusView.priority = .defaultLow
//            self.statusView.isHidden = true
//        }
//    }
    
    // Не стал удалять - потом понадобится =)
    
//    private func handleButtons(status: BusOrder.BookingStatus) {
//        switch status {
//        case .error, .fullyReturned, .cancelled, .partiallyReturned, .partiallyCancelled:
//            self.docButton.isHidden = false
//            self.returnButton.isHidden = true
//            self.refundDetailsButton.isHidden = false
//            self.needToPayLabel.isHidden = true
//        case .booked, .created:
//            self.docButton.isHidden = true
//            self.returnButton.isHidden = true
//            self.refundDetailsButton.isHidden = true
//            self.needToPayLabel.isHidden = false
//        case .paid:
//            self.docButton.isHidden = false
//            self.returnButton.isHidden = false
//            self.refundDetailsButton.isHidden = true
//            self.needToPayLabel.isHidden = true
//        }
//    }
    
    public func configure(with data: _TicketDetail) {
        self.onRefund = data.onRefund
        self.onDownload = data.onDownload
        self.placelabel.text = data.place
        self.onRefundDetails = data.onRefundDetails
        self.ticketPriceLabel.text = data.price
        self.ticketNumberLabel.text = data.number
        self.passengerDataLabel.text = data.passenger
        self.docButton.setTitle(data.downloadTitle, for: .normal)
        
//        self.handleButtons(status: data.status)
//        self.handleStatusView(status: data.status)
    }
    
    private func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.custom(for: .textSecondary).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
}
