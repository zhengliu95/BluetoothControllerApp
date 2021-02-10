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
    private var peripheralArray: [PeripheralItem] = []

    private var selectedRow: IndexPath?
    private var connectLabel: UILabel?
    
// MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set bluetoothhandler's delegate to self
        bluetoothHandler.delegate = self
        
        retry.isEnabled = false
        
        //check is Bluetooth is powered on
        if  bluetoothHandler.centralManager.state != .poweredOn {
            title = "Bluetooth not turned on"
            return
        }
        title = "Scanning"
        tableView.allowsSelection = false
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
        tableView.allowsSelection = true
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
        peripheralArray[selectedRow!.row].connectStatus = false
        let label = tableView.cellForRow(at: self.selectedRow!)!.viewWithTag(2) as! UILabel
        label.text = "Connection Failed"
        
        // stop scanning and save resources
        bluetoothHandler.stopScan()
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
        label.text = peripheralArray[(indexPath as NSIndexPath).row].peripheral!.name
        
        if  peripheralArray[indexPath.row].connectStatus == false{
            let label = cell.viewWithTag(2) as! UILabel
            label.text = "connect"
        }else{
            let label = cell.viewWithTag(2) as! UILabel
            label.text = "connecting"
        }
        
        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        // if have previous selected cell
        if let previousRow = selectedRow{
            // if previous cell is not the current selected cell
            if previousRow != indexPath{
                peripheralArray[previousRow.row].connectStatus = false
                bluetoothHandler.disconnect()
                
            }
                // else do nothing
            else {return}
        }
        
        selectedRow = indexPath
        peripheralArray[indexPath.row].connectStatus = true
        myPeripheral = peripheralArray[indexPath.row].peripheral
        bluetoothHandler.connectToPeripheral(myPeripheral)
        tableView.reloadData()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothTableViewController.connectTimeOut), userInfo: nil, repeats: false)
    }
    
    
// MARK: - Bluetooth delegate
    
    func bluetoothDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripheralArray {
            if exisiting.peripheral!.identifier == peripheral.identifier { return }
        }
        if let _ = peripheral.name {
            // add to the array, next sort & reload
            let theRSSI = RSSI?.floatValue ?? 0.0
            let newItem = PeripheralItem()
            newItem.peripheral = peripheral
            newItem.rssi = theRSSI
            newItem.connectStatus = false
            peripheralArray.append(newItem)
            peripheralArray.sort { $0.rssi < $1.rssi }
        }
        self.tableView.reloadData()
        
    }
    
    func bluetoothDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        self.retry.isEnabled = true
        peripheralArray[selectedRow!.row].connectStatus = false
        let label = tableView.cellForRow(at: self.selectedRow!)!.viewWithTag(2) as! UILabel
        label.text = "Connection Failed"
    }
    
    func bluetoothDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        self.retry.isEnabled = true
        peripheralArray[selectedRow!.row].connectStatus = false
        let label = tableView.cellForRow(at: self.selectedRow!)!.viewWithTag(2) as! UILabel
        label.text = "Connection Failed"
    }
    
    func bluetoothIsReady(_ peripheral: CBPeripheral) {
        // create the alert
        let alert = UIAlertController(title: "Success", message: "The Bluetooth is connected", preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            self.dismiss(animated: true, completion: nil)
        })
       

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    func bluetoothDidChangeState() {

        if bluetoothHandler.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "bluetoothOff"), object: self)
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
        
        if let theRow = selectedRow{
            peripheralArray[(theRow as NSIndexPath).row].connectStatus = false
        }
        peripheralArray = []
        
        self.title = "Scanning"
        self.selectedRow = nil
        self.retry.isEnabled = false
        self.tableView.reloadData()
        bluetoothHandler.startScan()
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothTableViewController.scanTimeOut), userInfo: nil, repeats: false)
         
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        bluetoothHandler.stopScan()
        dismiss(animated: true, completion: nil)
    }
    
    
}
