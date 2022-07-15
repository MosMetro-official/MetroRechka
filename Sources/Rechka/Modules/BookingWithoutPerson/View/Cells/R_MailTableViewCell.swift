//
//  R_MailTableViewCell.swift
//  MetroRechka
//
//  Created by Гусейн on 05.07.2022.
//

import UIKit
import CoreTableView

protocol _R_MailTableViewCell: CellData {
    var text: String? { get set }
    var placeholder: String { get set }
    var onTextEnter: Command<String> { get set }
    var onTextFinish: Command<String>? { get set }
}

extension _R_MailTableViewCell {
    
    func hashValues() -> [Int] {
        return [text.hashValue]
    }
    
    var height: CGFloat {
        return 44
    }
    
    var id: String {
        return "mailCell"
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? R_MailTableViewCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(R_MailTableViewCell.nib, forCellReuseIdentifier: R_MailTableViewCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R_MailTableViewCell.identifire, for: indexPath) as? R_MailTableViewCell else {
            return .init()
        }
        return cell
    }
    
}

class R_MailTableViewCell: UITableViewCell {

    @IBOutlet private var textField: UITextField!
    
    private var onTextChange: Command<String>?
    private var onTextFinish: Command<String>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with data: _R_MailTableViewCell) {
        self.textField.text = data.text
        self.textField.placeholder = data.placeholder
        self.onTextChange = data.onTextEnter
        self.onTextFinish = data.onTextFinish
    }
    
    @objc private func textDidChange(textField: UITextField) {
        onTextChange?.perform(with: textField.text ?? "")
    }
    
}

extension R_MailTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onTextFinish?.perform(with: textField.text ?? "")
    }
    
    
}
