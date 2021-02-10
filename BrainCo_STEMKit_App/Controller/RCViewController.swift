//
//  RCViewController.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 9/11/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import UIKit
import CoreBluetooth

class RCViewController: UIViewController, BluetoothDelegate {
    
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button4: UIButton!
    @IBOutlet weak var Button5: UIButton!
    @IBOutlet weak var Button6: UIButton!
    @IBOutlet weak var Button7: UIButton!
    @IBOutlet weak var Button8: UIButton!
    @IBOutlet weak var Button9: UIButton!
    @IBOutlet weak var ButtonFingWave: UIButton!
    @IBOutlet weak var Button0: UIButton!
    @IBOutlet weak var ButtonRockGes: UIButton!
    
    
    @IBAction func Send1(_ sender: UIButton) {
        let bytes : [UInt8] = [0x01]
        
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send2(_ sender: UIButton) {
        let bytes : [UInt8] = [0x08]
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send3(_ sender: UIButton) {
        let bytes : [UInt8] = [0x10]
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send4(_ sender: UIButton) {
        let bytes : [UInt8] = [0x20]
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send5(_ sender: UIButton) {
        let bytes : [UInt8] = [0x30]
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send6(_ sender: UIButton) {
        let bytes : [UInt8] = [0x35]
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send7(_ sender: UIButton) {
        let bytes : [UInt8] = [0x40]
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send8(_ sender: UIButton) {
        let bytes : [UInt8] = [0x50]
        print(Button8.titleLabel!.text!)
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func Send9(_ sender: UIButton) {
        let bytes : [UInt8] = [0x45]
        print(Button9.titleLabel!.text!)
        bluetoothHandler.sendBytesToDevice(bytes)
    }
    @IBAction func SendFingWave(_ sender: UIButton) {
        print(ButtonFingWave.titleLabel!.text!)
    }
    @IBAction func Send0(_ sender: UIButton) {
        print(Button0.titleLabel!.text!)
    }
    @IBAction func SendRockGes(_ sender: UIButton) {
        print(ButtonRockGes.titleLabel!.text!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothHandler.delegate = self
        // Do any additional setup after loading the view.
    }
    // MARK: - Bluetooth delegate
    func bluetoothDidChangeState() {
        if bluetoothHandler.centralManager.state != .poweredOn {
            print("state changed")
        }
    }
    
    func bluetoothDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print(error ?? "None")
        print("Disconnect")
    }
    
    func bluetoothDidReceiveBytes(_ bytes: [UInt8]) {
        print(bytes)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
