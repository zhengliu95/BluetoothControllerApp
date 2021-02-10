//
//  BluetoothClass.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 10/13/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import UIKit
import CoreBluetooth


var bluetoothHandler: BluetoothClass!

protocol BluetoothDelegate: class {
    // ** Required **
    
    // Called when the state of the CBCentralManager changes
    func bluetoothDidChangeState()
    
    // Called when a peripheral disconnected
    func bluetoothDidDisconnect(_ peripheral: CBPeripheral, error: NSError?)
    
    // ** Optionals **
    
    // Called when a message is received
    func bluetoothDidReceiveBytes(_ bytes: [UInt8])
    
    // Called when the RSSI of the connected peripheral is read
    func bluetoothDidReadRSSI(_ rssi: NSNumber)
    
    // Called when a new peripheral is discovered while scanning.
    func bluetoothDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?)
    
    // Called when a peripheral is connected (but not yet ready for cummunication)
    func bluetoothDidConnect(_ peripheral: CBPeripheral)
    
    // Called when a pending connection failed
    func bluetoothDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?)

    // Called when a peripheral is ready for communication
    func bluetoothIsReady(_ peripheral: CBPeripheral)
}

// Make some of the delegate functions optional
extension BluetoothDelegate {
    func bluetoothDidReceiveBytes(_ bytes: [UInt8]) {}
    func bluetoothDidReadRSSI(_ rssi: NSNumber) {}
    func bluetoothDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {}
    func bluetoothDidConnect(_ peripheral: CBPeripheral) {}
    func bluetoothDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {}
    func bluetoothIsReady(_ peripheral: CBPeripheral) {}
}

final class BluetoothClass: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    // MARK: - Variables
    // The delegate object the BluetoothDelegate methods will be called upon
    weak var delegate: BluetoothDelegate?
    
    var centralManager: CBCentralManager!
    
    // The peripheral we're trying to connect to (nil if none)
    var pendingPeripheral: CBPeripheral?
    // The connected peripheral (nil if none is connected)
    var connectedPeripheral: CBPeripheral?
    
    var peripheralArray: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    // The characteristic 0xFFE1 we need to write to, of the connectedPeripheral
    weak var writeCharacteristic: CBCharacteristic?
    
    // Whether it is ready to send and receive data
    var isReady: Bool {
        return centralManager.state == .poweredOn &&
        connectedPeripheral != nil &&
        writeCharacteristic != nil
    }
    
    // Whether it is looking for peripherals
    var isScanning: Bool {
        return centralManager.isScanning
    }
    
    // Whether the state of the centralManager is .poweredOn
    var isPoweredOn: Bool {
        return centralManager.state == .poweredOn
    }
    
    // MARK: - Functions
    // initialization
    init(delegate: BluetoothDelegate) {
        super.init()
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Start scanning for peripherals
    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        
        // start scanning for peripherals with correct service UUID
        centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particleServiceUUID], options: nil)
//        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        // retrieve peripherals that are already connected
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [ParticlePeripheral.particleServiceUUID])
        for peripheral in peripherals {
            delegate?.bluetoothDidDiscoverPeripheral(peripheral, RSSI: nil)
        }
    }
    
    // Stop scanning for peripherals
    func stopScan() {
        centralManager.stopScan()
    }
    
    // Try to connect to the given peripheral
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        pendingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    // Disconnect from the connected peripheral or stop connecting to it
    func disconnect() {
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
            connectedPeripheral = nil
        } else if let p = pendingPeripheral {
            centralManager.cancelPeripheralConnection(p)
            pendingPeripheral = nil
        }
    }
    
    // The didReadRSSI delegate function will be called after calling this function
    func readRSSI() {
        guard isReady else { return }
        connectedPeripheral!.readRSSI()
    }
    
    
    // Send an array of bytes to the device
    func sendBytesToDevice(_ bytes: [UInt8]) {
        guard isReady else { return }
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        connectedPeripheral?.writeValue(data, for: writeCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    
    // MARK: CBCentralManagerDelegate functions
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.bluetoothDidDiscoverPeripheral(peripheral, RSSI: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        
        // send it to the delegate
        delegate?.bluetoothDidConnect(peripheral)
        
        // Then discover service to comunicate with BLE
        peripheral.discoverServices([ParticlePeripheral.particleServiceUUID])
//        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        pendingPeripheral = nil

        // send it to the delegate
        delegate?.bluetoothDidDisconnect(peripheral, error: error as NSError?)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        pendingPeripheral = nil

        // just send it to the delegate
        delegate?.bluetoothDidFailToConnect(peripheral, error: error as NSError?)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // note that "didDisconnectPeripheral" won't be called if BLE is turned off while connected
        connectedPeripheral = nil
        pendingPeripheral = nil

        // send it to the delegate
        delegate?.bluetoothDidChangeState()
    }
    
    
    // MARK: CBPeripheralDelegate functions
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover the 0xFFE1 characteristic for all services (though there should only be one)
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([ParticlePeripheral.writeReadCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // check whether the characteristic we're looking for (0xFFE1) is present - just to make sure
        for characteristic in service.characteristics! {
            if characteristic.uuid == ParticlePeripheral.writeReadCharacteristicUUID {
                // subscribe to this value (so we'll get notified when there is serial data for us..)
                peripheral.setNotifyValue(true, for: characteristic)
                
                // keep a reference to this characteristic so we can write to it
                writeCharacteristic = characteristic
                
                // notify the delegate we're ready for communication
                delegate?.bluetoothIsReady(peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // notify the delegate
        let data = characteristic.value
        guard data != nil else { return }
        
        // bytes array
        var bytes = [UInt8](repeating: 0, count: data!.count / MemoryLayout<UInt8>.size)
        (data! as NSData).getBytes(&bytes, length: data!.count)
        delegate?.bluetoothDidReceiveBytes(bytes)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        delegate?.bluetoothDidReadRSSI(RSSI)
    }
    
}

