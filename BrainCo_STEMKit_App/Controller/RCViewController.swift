//
//  RCViewController.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 9/11/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import UIKit

class RCViewController: UIViewController {

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
        print(Button1.titleLabel!.text!)
    }
    @IBAction func Send2(_ sender: UIButton) {
        print(Button2.titleLabel!.text!)
    }
    @IBAction func Send3(_ sender: UIButton) {
        print(Button3.titleLabel!.text!)
    }
    @IBAction func Send4(_ sender: UIButton) {
        print(Button4.titleLabel!.text!)
    }
    @IBAction func Send5(_ sender: UIButton) {
        print(Button5.titleLabel!.text!)
    }
    @IBAction func Send6(_ sender: UIButton) {
        print(Button6.titleLabel!.text!)
    }
    @IBAction func Send7(_ sender: UIButton) {
        print(Button7.titleLabel!.text!)
    }
    @IBAction func Send8(_ sender: UIButton) {
        print(Button8.titleLabel!.text!)
    }
    @IBAction func Send9(_ sender: UIButton) {
        print(Button9.titleLabel!.text!)
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

}
