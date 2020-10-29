//
//  BluetoothTableViewController.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 9/28/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import UIKit
import CoreBluetooth



class BluetoothTableViewController: UITableViewController, BluetoothDelegate{
    
// MARK: - IBOutlets
    
    @IBOutlet weak var retry: UIBarButtonItem!
    
    
    // MARK: - Variables
    
    // The peripheral the user has selected
    private var myPeripheral: CBPeripheral!
    // The peripherals that have been discovered (sorted by asc RSSI)
    private var peripheralArray: [(peripheral: CBPeripheral, RSSI: Float)] = []

    private var selectedCell: UITableViewCell?
    private var connectLabel: UILabel?
    
// MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set bluetoothhandler's delegate to self
        bluetoothHandler.delegate = self
        
        //check is Bluetooth is powered on
        if  bluetoothHandler.centralManager.state != .poweredOn {
            title = "Bluetooth not turned on"
            return
        }
        title = "Scanning"
        retry.isEnabled = false
        // start scanning and schedule the time out
        bluetoothHandler.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothTableViewController.scanTimeOut), userInfo: nil, repeats: false)
        
    }
    
    // Should be called 10s after we've begun scanning
    @objc func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        bluetoothHandler.stopScan()
        retry.isEnabled = true
        title = "Done scanning"
    }
    
    // Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
        // do nothing if we've already connected
        if let _ = bluetoothHandler.connectedPeripheral {
            return
        }
        
        if let _ = myPeripheral {
            bluetoothHandler.disconnect()
            myPeripheral = nil
        }
        print("time out")
        let label = self.selectedCell!.viewWithTag(2) as! UILabel
        label.text = "Connection Failed"
        
        // stop scanning and save resources
        bluetoothHandler.stopScan()
    }
    
    
// MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //            if segue.identifier == "goToMenuSegue"{
        //                if let destVC = segue.destination as? UINavigationController,
        //                    let targetController = destVC.topViewController as? MenuViewController {
        //                    targetController.message = userName.text!
        //                }
        //
        //            }
    }
    
    
    
// MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
//        cell.textLabel!.text = peripheralArray[(indexPath as NSIndexPath).row].peripheral.name
        label.text = peripheralArray[(indexPath as NSIndexPath).row].peripheral.name
        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        // if have previous selected cell
        if let previousCell = selectedCell{
            // if previous cell is not the current selected cell
            if previousCell != self.tableView.cellForRow(at: indexPath){
                let label = previousCell.viewWithTag(2) as! UILabel
                label.text = "connect"
                bluetoothHandler.disconnect()
            }
            else {return}
        }
        
        selectedCell = self.tableView.cellForRow(at: indexPath)
        let label = selectedCell?.viewWithTag(2) as! UILabel
        label.text = "Connecting"
        myPeripheral = peripheralArray[indexPath.row].peripheral
        bluetoothHandler.connectToPeripheral(myPeripheral)
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothTableViewController.connectTimeOut), userInfo: nil, repeats: false)
    }
    
    
// MARK: - Bluetooth delegate
    
    func bluetoothDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripheralArray {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        if let _ = peripheral.name {
            // add to the array, next sort & reload
            let theRSSI = RSSI?.floatValue ?? 0.0
            peripheralArray.append((peripheral: peripheral, RSSI: theRSSI))
            peripheralArray.sort { $0.RSSI < $1.RSSI }
        }
        self.tableView.reloadData()
        
    }
    
    func bluetoothDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        self.retry.isEnabled = true
        let label = self.selectedCell!.viewWithTag(2) as! UILabel
        label.text = "Connection Failed"
    }
    
    func bluetoothDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        self.retry.isEnabled = true
        let label = self.selectedCell!.viewWithTag(2) as! UILabel
        label.text = "Connection Failed"
    }
    
    func bluetoothIsReady(_ peripheral: CBPeripheral) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "bluetoothStateChanged"), object: self)
        dismiss(animated: true, completion: nil)
    }
    
    func bluetoothDidChangeState() {
        
        if bluetoothHandler.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "bluetoothStateChanged"), object: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
// MARK: - IBActions
    
    @IBAction func rescan(_ sender: UIBarButtonItem) {
        peripheralArray = []
        if let theCell = self.selectedCell{
            let label = theCell.viewWithTag(2) as! UILabel
            label.text = "connect"
        }
        self.tableView.reloadData()
        self.title = "Scanning"
        self.selectedCell = nil
        self.retry.isEnabled = false
        bluetoothHandler.startScan()
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothTableViewController.scanTimeOut), userInfo: nil, repeats: false)
         
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        bluetoothHandler.stopScan()
        dismiss(animated: true, completion: nil)
    }
    
    
}

//// MARK: - CBCentralManagerDelegate
//
//extension BluetoothTableViewController: CBCentralManagerDelegate{
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        print("Central state update")
//        if central.state != .poweredOn {
//            print("Central is not powered on")
//        } else {
//            central.scanForPeripherals(withServices: nil, options: nil)
//        }
//    }
//
//
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//
//        print("Connected to your Particle Board")
//        peripheral.discoverServices(nil)
//
//    }
//
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//
//
//        //            if let pname = peripheral.name {
//
//        //                print(pname)
//        // add scanned peripheral to the array
//
//        //not sure if it works
//        //                if pname == "HM_10" {
//        //                    self.centralManager.stopScan()
//        //                    self.myPeripheral = peripheral
//        //                    self.myPeripheral.delegate = self
//        //                    self.centralManager.connect(peripheral, options: nil)
//        //                }
//        if peripheral.name != nil{
//            //check if array contains the scanned peripheral
//            for exisiting in peripheralArray {
//                if exisiting.peripheral.identifier == peripheral.identifier { return }
//            }
//
//            peripheralArray.append((peripheral: peripheral, RSSI: RSSI.floatValue ))
//            peripheralArray.sort { $0.RSSI < $1.RSSI }
//            self.tableView.reloadData()
//        }
//        // enable retry button
//        self.retry.isEnabled = true
//
//    }
//
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        if peripheral == myPeripheral {
//            print("Disconnected")
//            myPeripheral = nil
//        }
//    }
//
//}
//
//// MARK: - CBPeripheralDelegate
//extension BluetoothTableViewController: CBPeripheralDelegate{
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services {
//            for service in services {
//                if service.uuid == ParticlePeripheral.particleServiceUUID {
//                    print("Bluetooth module service found")
//
//                    peripheral.discoverCharacteristics(nil, for: service)
//                    return
//                }
//            }
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let characteristics = service.characteristics {
//            for characteristic in characteristics {
//                if characteristic.uuid == ParticlePeripheral.writeReadCharacteristicUUID {
//                    print("Bluetooth module characteristic found")
//                    myCharacteristics = characteristic
//                    // subscribe regular notification
//                    peripheral.setNotifyValue(true, for: characteristic)
//                }
//            }
//        }
//    }
//}
