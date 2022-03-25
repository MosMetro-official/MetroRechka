//
//  FieldCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _Field: CellData {
    var text: String? { get }
    var placeholder: String { get }
    var textFieldType: UIKeyboardType { get }
    var onFieldEdit: (UITextField) -> () { get }
    var onTap: () -> () { get }
}

extension _Field {
    var text: String? {
        return nil
    }
    
    var textFieldType: UIKeyboardType {
        return .default
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? FieldCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(FieldCell.nib, forCellReuseIdentifier: FieldCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.identifire, for: indexPath) as? FieldCell else { return .init() }
        return cell
    }
}

class FieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    var handleText: ((UITextField) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }
    
    public func configure(with data: _Field) {
        textField.text = data.text
        textField.placeholder = data.placeholder
        textField.keyboardType = data.textFieldType
        handleText = data.onFieldEdit
    }
    
    @IBAction func textEnter(_ sender: UITextField) {
        handleText?(sender)
    }
}
