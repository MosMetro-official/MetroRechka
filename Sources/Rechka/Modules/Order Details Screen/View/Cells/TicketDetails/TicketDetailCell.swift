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
    var status: String { get }
    var buttons: TicketDetailCell.Buttons { get }
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
            passenger.hashValue
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TicketDetailCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TicketDetailCell.identifire, bundle: Rechka.shared.bundle), forCellReuseIdentifier: TicketDetailCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TicketDetailCell.identifire, for: indexPath) as? TicketDetailCell
        else { return .init() }
        return cell
    }
}

class TicketDetailCell: UITableViewCell {
    
    struct Buttons {
        let onRefund: ButtonData?
        let onDownload: ButtonData?
        let onRefundDetails: ButtonData?
        let info: ButtonData?
        
        struct ButtonData {
            let title: String
            let onSelect: Command<Void>?
        }
    }

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
        
        drawDottedLine(start: CGPoint(x: 12, y: 12), end: CGPoint(x: (UIScreen.main.bounds.width - 40 - 12), y: 12), view: separatorView)
    }
    
    public func configure(with data: _TicketDetail) {
        self.placelabel.text = data.place
        self.ticketPriceLabel.text = data.price
        self.ticketNumberLabel.text = data.number
        self.passengerDataLabel.text = data.passenger
        self.docButton.isHidden = data.buttons.onDownload == nil
        self.returnButton.isHidden = data.buttons.onRefund == nil
        self.refundDetailsButton.isHidden = data.buttons.onRefundDetails == nil
        self.needToPayLabel.isHidden = data.buttons.info == nil
        self.onDownload = data.buttons.onDownload?.onSelect
        self.onRefund = data.buttons.onRefund?.onSelect
        self.onRefundDetails = data.buttons.onRefundDetails?.onSelect
        self.statusLabel.text = data.status
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
