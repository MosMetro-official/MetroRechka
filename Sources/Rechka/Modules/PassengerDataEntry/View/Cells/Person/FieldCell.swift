//
//  FieldCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _Field: CellData {
    var placeholder: String { get }
    var textFieldType: UIKeyboardType { get }
    var onFieldEdit: (UITextField) -> () { get }
    var onTap: () -> () { get }
}

extension _Field {
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
    
    var closure: ((UITextField) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _Field) {
        textField.placeholder = data.placeholder
        textField.keyboardType = data.textFieldType
        closure = data.onFieldEdit
    }
    
    @IBAction func tf(_ sender: UITextField) {
        closure?(sender)
    }
}
