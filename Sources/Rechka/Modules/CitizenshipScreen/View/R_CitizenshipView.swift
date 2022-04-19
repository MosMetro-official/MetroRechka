//
//  R_CitizenshipView.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_CitizenshipView: UIView {
    
    @IBOutlet weak var tableView: BaseTableView!
    @IBOutlet weak var searchViewToBottom: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    var handleSearhText: ((String) -> Void)?
    
    struct ViewState {
        let onClose: Command<Void>?
        let dataState: DataState
        let state: [State]
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        struct Citizenship: _Citizenship {
            let title: String
            let onItemSelect: Command<Void>
        }
        
        static let initial = R_CitizenshipView.ViewState(onClose: nil, dataState: .loading, state: [])
    }
    
    var viewState: ViewState = .initial {
        didSet {
            DispatchQueue.main.async {
                self.render()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func onCloseTap() {
        viewState.onClose?.perform(with: ())
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        handleSearhText?(text)
    }
    
    private func render() {
        switch viewState.dataState {
        case .loading:
            self.showBlurLoading(on: self)
        case .loaded:
            self.removeBlurLoading(from: self)
        case .error:
            self.removeBlurLoading(from: self)
        }
        self.tableView.viewStateInput = viewState.state
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let endFrameY = endFrame.origin.y
        let endFrameHeight = endFrame.height
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        if endFrameY >= UIScreen.main.bounds.size.height {
            self.tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 44, right: 0)
        } else {
            self.tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: endFrameHeight + 44, right: 0)
            self.searchViewToBottom.constant = endFrameHeight - 25
            tableView.setContentOffset(tableView.contentOffset, animated:false)
        }
        tableView.onScroll = { [weak self] scrollView in
            guard let self = self else { return }
            if scrollView.contentOffset.y > 5 {
                self.searchViewToBottom.constant = 0
                self.textField.resignFirstResponder()
            }
        }
        
        print("END FRAME - \(endFrame), endFrameY - \(endFrameY)")
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.layoutIfNeeded() },
            completion: nil)
    }
}
