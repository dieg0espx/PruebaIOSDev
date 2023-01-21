//
//  RegisterViewController.swift
//  pruebaIOS
//
//  Created by DIEGO ESPINOSA on 2023-01-21.
//

import UIKit
import SQLite

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_username: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var txt_confirmPassword: UITextField!
    @IBOutlet weak var btn_createAccount: UIButton!
    
    var database:Connection!
    let usersTable  = Table("users")
    let  id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    let password = Expression<String>("password")
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("New Account..")
        // Do any additional setup after loading the view.
        do {
            //CREATING A FILE
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            //CREATING FILE NAME WITH ITS EXTENSION
            let fileURL = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            //CREATING DATABASE, IT'S STORED IN THAT FILE PATH
            let database = try Connection(fileURL.path)
            self.database = database
        }
        catch {
            print(error)
        }
    }
    
    
    func alert(title:String, content:String){
        // Create new Alert
        let dialogMessage = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Try Again", style: .default)
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @IBAction func btnCreateAccountClicked(_ sender: Any) {
        let name = txt_name.text!
        let username = txt_username.text!
        let password = txt_password.text!
        let confirmPassword = txt_confirmPassword.text!
        
        
        //VALIDATING NONE EMPTY FIELDS
        if(name.isEmpty == false && username.isEmpty == false && password.isEmpty == false && confirmPassword.isEmpty == false){
            //VALIDATING PASSWORD & CONFIRM PASSWORD
            if(password == confirmPassword){
                //VALIDATING EMAIL IN USE
                do {
                    let users = try self.database.prepare(self.usersTable)
                    for user in users {
                        if(user[self.email] == username){
                            alert(title: "Error !", content: "Email already in use")
                        } else {
                            //WRITING INTO THE DATABASE
                            let insertUser = self.usersTable.insert(self.name <- name, self.email <- username, self.password <- password)
                            do {
                                try self.database.run(insertUser)
                                print("User Inserted")
                                //Storing  current username
                                defaults.set(username, forKey: "currentUsername")
                                defaults.set(password, forKey: "currentPassword")
                                defaults.set(name, forKey: "currentName")
                                //MOVING TO ANOTHER VIEWCONTROLLER
                                let vc = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                                vc.modalPresentationStyle = .fullScreen
                                present(vc, animated: false)
                                break
                            } catch {
                                print(error)
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            } else {
                alert(title: "Ups!", content: "Your passwords are not matching")
            }
        } else {
            alert(title: "Ups!", content: "You are missing some fields")
        }
        
        
        
        
    }
}
