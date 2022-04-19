//
//  TicketsCell.swift
//  
//
//  Created by Слава Платонов on 17.03.2022.
//

import UIKit
import CoreTableView

protocol _Tickets: CellData {
    var ticketList: [R_Tariff] { get }
    var onChoice: ((Int) -> ())? { get }
    var selectedTicket: R_Tariff? { get }
}

extension _Tickets {
    var selectedTicket: R_Tariff? { return nil }
    var onChoice: ((Int) -> ())? { return nil }
    
    var height: CGFloat {
        return 130
    }
    
    func hashValues() -> [Int] {
        return [selectedTicket.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TicketsCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(TicketsCell.nib, forCellReuseIdentifier: TicketsCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TicketsCell.identifire, for: indexPath) as? TicketsCell else { return .init() }
        return cell
    }
}

class TicketsCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var model: [R_Tariff]? {
        didSet {
            collectionView.reloadData()
        }
    }
    private var choiceTicket: ((Int) -> ())?
    private var selectedTicket: R_Tariff?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(TicketCell.nib, forCellWithReuseIdentifier: TicketCell.identifire)
        collectionView.register(EmptyTicketCell.nib, forCellWithReuseIdentifier: EmptyTicketCell.identifire)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
  
    public func configure(with data: _Tickets) {
        model = data.ticketList
        choiceTicket = data.onChoice
        selectedTicket = data.selectedTicket
    }
}

extension TicketsCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch model?.count {
        case 0:
            return 1
        default:
            return model?.count ?? 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let ticket = model?[indexPath.item] {
            switch model?.count {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyTicketCell.identifire, for: indexPath) as? EmptyTicketCell else { return .init() }
                return cell
            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.identifire, for: indexPath) as? TicketCell else { return .init() }
                let isSelect = ticket == selectedTicket
                cell.configure(with: ticket, isSelect: isSelect)
                return cell
            }
        }
        return .init()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        choiceTicket?(indexPath.item)
    }
}

extension TicketsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch model?.count {
        case 0:
            return CGSize(width: UIScreen.main.bounds.width - 20, height: collectionView.frame.height)
        default:
            return CGSize(width: UIScreen.main.bounds.width * 0.4, height: collectionView.frame.height - 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
    }
}
