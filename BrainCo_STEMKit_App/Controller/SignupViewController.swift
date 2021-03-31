//
//  SignupViewController.swift
//  BrainCo_STEMKit_App
//
//  Created by Zheng Liu on 3/23/21.
//  Copyright © 2021 Zheng Liu. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var emailFirst: UITextField!
    @IBOutlet weak var emailSecond: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func Register(_ sender: Any) {
        
        if let name = username.text{
            if name.count == 0 || name.count > 20 {
                let alert = UIAlertController(title: "Invalid Input", message: "Username's length should be within 1 to 20.", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }
        }
        
        if let pw = password.text{
            guard pw.containsNumber && pw.containsLowerCase && pw.containsUpperCase && pw.containsSpecialCharacter else{
                let alert = UIAlertController(title: "Invalid Input", message: "Password should contains at least 1 number, 1 upper case character, 1 lower case character, and 1 special character.", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }
        }
        
        if let first = emailFirst.text, let second = emailSecond.text {
            guard first.elementsEqual(second) else{
                let alert = UIAlertController(title: "Invalid Input", message: "Emails do not match!", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }
            guard first.containsAt else{
                let alert = UIAlertController(title: "Invalid Input", message: "Email is not valid!", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }
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

}

extension String {
    var containsSpecialCharacter: Bool {
        let regex = ".*[^A-Za-z0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    var containsUpperCase: Bool {
        let regex = ".*[A-Z].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    var containsLowerCase: Bool {
        let regex = ".*[a-z].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    var containsNumber: Bool {
        let regex = ".*[0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    var containsAt: Bool {
        let regex = ".*[@].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
}
