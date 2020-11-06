//
//  PeripheralItem.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 11/1/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralItem {
    var peripheral: CBPeripheral? = nil
    var rssi: Float = 0.0
    var connectStatus: Bool = false
}
