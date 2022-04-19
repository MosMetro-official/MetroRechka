//
//  InputView.swift
//  
//
//  Created by Слава Платонов on 28.03.2022.
//

import UIKit

typealias TextEnterData = (text: String, textField: UITextField)

typealias TextValidationData = (text: String, textField: UITextField, replacementString: String)

internal final class InputView : UIView {
    
    @IBOutlet var backgroundBlurView: UIView!
    
    @IBOutlet var floatingView: UIView!
    
    @IBOutlet var descLabel: UILabel!
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var floatingHeightAnchor: NSLayoutConstraint!
    
    private var bottomSafeArea: CGFloat = 0
    
    @IBAction func handleSubmit(_ sender: UIButton) {
        viewState.onNext()
    }
    
    @IBAction func handleBack(_ sender: Any) {
        viewState.onBack()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    struct ViewState : Equatable {
        static func == (lhs: InputView.ViewState, rhs: InputView.ViewState) -> Bool {
            return lhs.id == rhs.id
        }
        let id: Int
        let desc: String
        let text: String?
        let placeholder: String
        let onTextEnter: (TextEnterData) -> Void
        let keyboardType: UIKeyboardType
        let onNext: () -> ()
        let onBack: () -> ()
        var nextImage: UIImage
        let backImageEnabled: Bool
        var validation: ((TextValidationData) -> Bool)?
        
        static let initial = ViewState.init(
            id: 0,
            desc: "",
            text: nil,
            placeholder: "",
            onTextEnter: { _ in},
            keyboardType: .default,
            onNext: {},
            onBack: {},
            nextImage: UIImage(),
            backImageEnabled: false
        )
    }
    
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
}

extension InputView {
    
    private func render() {
        DispatchQueue.main.async {
            self.backButton.isEnabled = self.viewState.backImageEnabled
            self.submitButton.setImage(self.viewState.nextImage, for: .normal)
            self.descLabel.text = self.viewState.desc
            self.textField.text = self.viewState.text
            self.textField.textColor = .custom(for: .textPrimary)
            self.textField.placeholder = self.viewState.placeholder
            self.textField.keyboardType = self.viewState.keyboardType
            self.textField.reloadInputViews()
        }
        
    }
    
    @objc private func handleOutsideTap() {
        self.textField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewState.onTextEnter((text: text, textField: textField))
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var isShowing = true
        guard let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let endFrameY = endFrame.origin.y
        let endFrameHeight = endFrame.height
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        if endFrameY >= UIScreen.main.bounds.size.height {
            self.floatingHeightAnchor.constant = self.bottomSafeArea + 24
            isShowing = false
            print("KEYBOARD WAS HIDED")
        } else {
            isShowing = true
            self.floatingHeightAnchor.constant = endFrameHeight + 80
        }
        print("END FRAME - \(endFrame), endFrameY - \(endFrameY)")
        
        let completion: (Bool) -> Void = { [weak self] completed in
            if completed {
                self?.removeFromSuperview()
            }
        }
        
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: {
                self.layoutIfNeeded()
                self.floatingView.alpha = isShowing ? 1 : 0
                self.backgroundBlurView.alpha = isShowing ? 0.7 : 0
                
            },
            completion: isShowing ? nil : completion)
    }
    
    private func setup() {
        self.submitButton.transform = self.submitButton.transform.rotated(by: CGFloat(Double.pi))
        self.backgroundBlurView.alpha = 0
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        floatingView.roundCorners(.top, radius: 16)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap))
        tapGesture.numberOfTapsRequired = 1
        backgroundBlurView.addGestureRecognizer(tapGesture)
        textField.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.bottomSafeArea = self.safeAreaInsets.bottom
            self.layoutIfNeeded()
            self.textField.becomeFirstResponder()
        })
    }
}

extension InputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let validation = self.viewState.validation, let text = textField.text {
            return validation((text: text, textField: textField, replacementString: string))
        }
        return true
    }
}

extension UIView {
    
    func showInputView(error: String) {
        if let currentView = self.viewWithTag(1337) as? InputView {
            let propertyAnimator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.3) {
                currentView.descLabel.textColor = .red
                currentView.descLabel.text = error
                currentView.floatingView.transform = CGAffineTransform(translationX: 20, y: 0)
                }

                propertyAnimator.addAnimations({
                    currentView.floatingView.transform = CGAffineTransform(translationX: 0, y: 0)
                }, delayFactor: 0.2)

                propertyAnimator.addCompletion { (_) in
                    currentView.descLabel.textColor = .custom(for: .textSecondary)
                    currentView.descLabel.text = currentView.viewState.desc
                }
                propertyAnimator.startAnimation()
        }
    }
    
    func showInput(with state: InputView.ViewState) {
        if let currentView = self.viewWithTag(1337) as? InputView {
            currentView.viewState = state
        } else {
            let inputView = InputView.loadFromNib()
            inputView.translatesAutoresizingMaskIntoConstraints = false
            inputView.tag = 1337
            self.addSubview(inputView)
            NSLayoutConstraint.activate(
                [
                    inputView.leftAnchor.constraint(equalTo: leftAnchor),
                    inputView.rightAnchor.constraint(equalTo: rightAnchor),
                    inputView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    inputView.topAnchor.constraint(equalTo: topAnchor)
                ]
            )
            inputView.viewState = state
        }
    }
    
    func hideInput() {
        if let currentView = self.viewWithTag(1337) as? InputView {
            currentView.textField.resignFirstResponder()
        }
    }
}
