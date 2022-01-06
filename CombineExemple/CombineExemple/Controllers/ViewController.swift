//
//  ViewController.swift
//  CombineExemple
//
//  Created by Jose Martins on 10/05/21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var swAllowMessage: UISwitch!
    
    @IBOutlet var btnSendMessage: UIButton!
    
    @IBOutlet var lblMessage: UILabel!
    
    @Published var canSendMessage: Bool = false
    
    private var switchSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProcesscingChain()
        setupProcesscingChainForPassthrough()
    }
    
    func setupProcesscingChainForPassthrough() {
        let weatherPublisher = PassthroughSubject<Int, WeatherError>()

        let subscriber = weatherPublisher
//            .filter { $0 > 20 }
            .sink { error in
                print("Erro Recebido")
            } receiveValue: { value in
                print("A temperatura é: \(value) ˚C")
            }


        weatherPublisher.send(10)
        weatherPublisher.send(20)
        weatherPublisher.send(25)

        subscriber.cancel()
        
        weatherPublisher.send(18)
        weatherPublisher.send(9)
        weatherPublisher.send(30)

//        weatherPublisher.send(completion: Subscribers.Completion<WeatherError>.failure(.thingsHappen))

    }
    
    func setupProcesscingChain() {
        switchSubscriber = $canSendMessage.receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: btnSendMessage)
        
        let messagePublisher = NotificationCenter.Publisher(center: .default, name: .newMessage)
            .map { notification -> String? in
                return (notification.object as? Message)?.content
            }
        
        let messagerSubscriber = Subscribers.Assign(object: lblMessage, keyPath: \.text)
        
        messagePublisher.subscribe(messagerSubscriber)
    }

    @IBAction func didSwitch(_ sender: UISwitch) {
        canSendMessage = sender.isOn
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = Message(content: "Hi, the current dateTime is \(Date())")
        
        NotificationCenter.default.post(name: .newMessage, object: message)
    }
}

struct Message {
    let content: String
}

extension Notification.Name {
    static let newMessage = Notification.Name("newMessage")
}

enum WeatherError: Error {
    case thingsHappen
}
