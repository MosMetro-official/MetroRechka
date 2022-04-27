//
//  ViewController.swift
//  RechkaExample
//
//  Created by Гусейн on 27.04.2022.
//

import UIKit
import MetroRechka

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = Rechka.shared.showRechkaFlow()
        self.present(vc, animated: true, completion: nil)
    }


}

