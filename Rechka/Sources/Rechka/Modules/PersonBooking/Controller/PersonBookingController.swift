//
//  PersonBookingController.swift
//  
//
//  Created by Слава Платонов on 21.03.2022.
//

import UIKit

class PersonBookingController: UIViewController {
    
    let nestedView = PersonBookingView(frame: UIScreen.main.bounds)
        
    var model: FakeModel!
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: image for back button
        nestedView.configureTitle(with: model)
        setupPersonAlert()
        title = "Покупка"
    }
    
    private func setupPersonAlert() {
        nestedView.showPersonAlert = { [weak self] in
            guard let self = self else { return }
            guard let users = SomeCache.shared.cache["user"] as? [String] else { return }
            var actions: [UIAlertAction] = []
            users.forEach { user in
                let action = UIAlertAction(title: user, style: .default) { _ in
                    print("action alert")
                }
                actions.append(action)
            }
            let personAlert = UIAlertController(title: "Persons", message: "", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            personAlert.addAction(cancelAction)
            self.present(personAlert, animated: true)
        }
        
        nestedView.showPersonDataEntry = {
            self.pushPersonDataEntry()
        }
    }
    
    public func pushPersonDataEntry(with user: String? = nil) {
        //let personDataEntry = PersonDataEntryController()
        //navigationController?.pushViewController(personDataEntry, animated: true)
    }
}
