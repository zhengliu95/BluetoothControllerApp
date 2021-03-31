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
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var macAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        password.delegate = self
        macAddress.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToMenuButton(_ sender: UIButton) {
        // send http request to db
        // create the alert
        let alert = UIAlertController(title: "Invalid Input", message: "All 3 blanks need to be filled", preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        guard  userName.text != "" &&  password.text != ""  && macAddress.text != "" else{
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        
//        let user = UserModel(username: userName.text!, password: password.text!, macAddress: macAddress.text!)
        let url = URL(string: "http://192.168.0.109:8084/users/\(userName.text!)")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTYxMzA5NDIzOH0.MP8LblAuxBZLlzwXEO2qANHqzrPfzRadsV9JXatV6Jz0phte6KbQmAatsOpX3XUlAuo1lOIT7Ui1tYBjliOY9Q", forHTTPHeaderField: "Authorization")
       
        do{
//            let jsonData = try JSONEncoder().encode(user)
//            request.httpBody = jsonData
            let session =  URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                    
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                guard let data = data else {return}
                do{
                    let theUser = try JSONDecoder().decode(UserModel.self, from: data)
//                    print("Username:\n \(theUser.username)")
//                    print("Password: \(theUser.password)")
//                    print("Mac Address: \(theUser.macAddress)")
                    print(theUser)
                }catch let jsonErr{
                    print(jsonErr)
                }
             
            }
            task.resume()
            self.performSegue(withIdentifier: "goToMenuSegue", sender: self)
            
            
        }catch let error{
            print(error)
        }
        
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
        password.resignFirstResponder()
        macAddress.resignFirstResponder()
        return true
    }
    


}

