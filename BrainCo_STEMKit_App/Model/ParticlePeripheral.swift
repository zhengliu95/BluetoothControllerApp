//
//  ParticlePeripheral.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 9/18/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import UIKit
import CoreBluetooth


class ParticlePeripheral: NSObject {

    // MARK: - Particle services and charcteristics Identifiers
    public static let particleServiceUUID     = CBUUID(string: "FFE0")
    public static let writeReadCharacteristicUUID   = CBUUID(string: "FFE1")

}
