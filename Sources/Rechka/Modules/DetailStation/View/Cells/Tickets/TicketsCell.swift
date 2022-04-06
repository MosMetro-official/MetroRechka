//
//  TicketsCell.swift
//  
//
//  Created by Слава Платонов on 17.03.2022.
//

import UIKit
import CoreTableView

protocol _Tickets: CellData {
    var ticketList: FakeModel { get }
    var onChoice: ((Int) -> ())? { get }
    var isSelectable: Bool { get }
}

extension _Tickets {
    var onChoice: ((Int) -> ())? { return nil }
    
    var height: CGFloat {
        return 60
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
    var model: FakeModel? {
        didSet {
            collectionView.reloadData()
        }
    }
    private var choiceTicket: ((Int) -> ())?
    private var isSelectable: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(TicketCell.nib, forCellWithReuseIdentifier: TicketCell.identifire)
        collectionView.register(EmptyTicketCell.nib, forCellWithReuseIdentifier: EmptyTicketCell.identifire)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
  
    public func configure(with data: _Tickets) {
        model = data.ticketList
        isSelectable = data.isSelectable
        choiceTicket = data.onChoice
    }
}

extension TicketsCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch model?.ticketsCount {
        case 0:
            return 1
        default:
            return model?.ticketsList.count ?? 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let ticket = model?.ticketsList[indexPath.row] {
            switch model?.ticketsCount {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyTicketCell.identifire, for: indexPath) as? EmptyTicketCell else { return .init() }
                return cell
            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.identifire, for: indexPath) as? TicketCell else { return .init() }
                cell.isSelectable = isSelectable ?? false
                cell.configure(with: ticket)
                return cell
            }
        }
        return .init()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch model?.ticketsCount {
        case 0:
            break
        default:
            if isSelectable ?? false {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.identifire, for: indexPath) as? TicketCell else { return }
                cell.isSelectable = isSelectable ?? false
                choiceTicket?(indexPath.row)
                cell.isSelected.toggle()
            }
        }
    }
}

extension TicketsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch model?.ticketsCount {
        case 0:
            return CGSize(width: UIScreen.main.bounds.width - 20, height: collectionView.frame.height)
        default:
            return CGSize(width: UIScreen.main.bounds.width * 0.4, height: collectionView.frame.height - 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if isSelectable ?? true {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
        }
    }
}