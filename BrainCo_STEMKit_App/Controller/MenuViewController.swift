//
//  MenuViewController.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 9/11/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import UIKit
import CoreBluetooth

class MenuViewController: UIViewController, BluetoothDelegate {

    var message: String?
    
    
    @IBOutlet weak var ShowMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let hasText = message{
            ShowMessage.textAlignment = .center
            ShowMessage.text = "Hello! \(hasText)"
            
        }
        bluetoothHandler = BluetoothClass(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.showAlert), name: NSNotification.Name(rawValue: "bluetoothOff"), object: nil)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // objective-c function 
    @objc func showAlert(){
        // create the alert
        let alert = UIAlertController(title: "Warning", message: "The Bluetooth is off, please connect again", preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
// MARK: - BluetoothDelegate
    func bluetoothDidChangeState() {
        return
        
    }
    
    func bluetoothDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        return
    }

}
