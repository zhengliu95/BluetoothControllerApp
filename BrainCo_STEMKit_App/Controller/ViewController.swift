//
//  ViewController.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 9/1/20.
//  Copyright © 2020 Zheng Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var pairCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        pairCode.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToMenuButton(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "goToMenuSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMenuSegue"{
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? MenuViewController {
                targetController.message = userName.text!
            }
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userName.resignFirstResponder()
        pairCode.resignFirstResponder()
        return true
    }
    


}

