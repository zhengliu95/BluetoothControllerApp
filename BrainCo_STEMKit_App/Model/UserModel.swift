//
//  UserModel.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 2/11/21.
//  Copyright © 2021 Zheng Liu. All rights reserved.
//

import Foundation

struct UserModel: Codable {
    var username: String
    var password: String
    var macAddress: String
}
