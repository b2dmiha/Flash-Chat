//
//  LogInViewController.swift
//  Flash Chat
//
//  Created by Michael Gimara on 31/03/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "goToChat" {
                let destinationVC = segue.destination as! ChatViewController
                destinationVC.user = sender as? User
            }
        }
    }
 
    //MARK: - Actions
    @IBAction func logInPressed(_ sender: AnyObject) {
        let email = emailTextfield.text! 
        let password = passwordTextfield.text!
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            SVProgressHUD.dismiss()
            
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if let user = authDataResult?.user {
                self.performSegue(withIdentifier: "goToChat", sender: user)
            }
        }
    }
}  
