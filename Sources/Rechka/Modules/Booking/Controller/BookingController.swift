//
//  BookingController.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView

// TODO: Удалить
extension Date {
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}

final class BookingController : UIViewController {
    
    private var timer: Timer?
    
    private var endTime = Date().adding(minutes: 1)
    
    var nestedView = BookingView(frame: UIScreen.main.bounds)
    
    override func loadView() {
        self.view = nestedView
        nestedView.onClose = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeDummyState()
        self.runCountdown()
    }
    
    var countdown: DateComponents {
        return Calendar.current.dateComponents([.minute, .second], from: Date(), to: endTime)
    }
    
    var currentTime : String = "20:00" {
        didSet {
            self.makeDummyState()
        }
    }
    
    @objc
    func updateTime() {
        let minutes = countdown.minute!
        let seconds = countdown.second!
        if minutes == 0, seconds == 0 {
            timer?.invalidate()
        }
        currentTime = String(format: "%02d:%02d", minutes, seconds)
    }

    func runCountdown() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    private func makeDummyState() {
        var topElements = [Element]()
        let title = BookingView.ViewState.Title(
            title: "Билеты забронированы"
        ).toElement()
        topElements.append(title)
        let timer = BookingView.ViewState.Timer(
            timer: self.currentTime,
            descr: "Осталось времени для оплаты"
        ).toElement()
        topElements.append(timer)
        var cancelElements = [Element]()
        let cancel = BookingView.ViewState.Cancel(
            title: "Отменить бронирование",
            onSelect: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let controller = CancelBookingController()
                    controller.modalTransitionStyle = .crossDissolve
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            }
        ).toElement()
        cancelElements.append(cancel)
        let topSection = SectionState(header: nil, footer: nil)
        let topState = State(model: topSection, elements: topElements)
        
        let cancelSection = SectionState(header: nil, footer: nil)
        let cancelState = State(model: cancelSection, elements: cancelElements)
        
        self.nestedView.viewState.states = [topState, cancelState]
    }
}
