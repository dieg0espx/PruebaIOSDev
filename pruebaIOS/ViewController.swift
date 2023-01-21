//
//  ViewController.swift
//  pruebaIOS
//
//  Created by DIEGO ESPINOSA on 2023-01-20.
//

import UIKit
import SQLite

class ViewController: UIViewController {
    
    
    @IBOutlet weak var txt_Email: UITextField!
    @IBOutlet weak var txt_Password: UITextField!
    
    var database:Connection!
    
    let usersTable  = Table("users")
    let  id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    let password = Expression<String>("password")
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = defaults.object(forKey:"currentUsername") as? String
        let currentPassword = defaults.object(forKey:"currentPassword") as? String
        txt_Email.text = currentUser
        txt_Password.text = currentPassword
      
       
        do {
            //CREATING A FILE
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            //CREATING FILE NAME WITH ITS EXTENSION
            let fileURL = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            //CREATING DATABASE, IT'S STORED IN THAT FILE PATH
            let database = try Connection(fileURL.path)
            self.database = database
            let users = try self.database.prepare(self.usersTable)
            for user in users {
                print(user[self.email])
            }
        }
        catch {
            print(error)
        }
        
        //CREATING TABLE
        let createTable = self.usersTable.create { (table) in
            table.column(self.id,  primaryKey:  true)
            table.column(self.name)
            table.column(self.email, unique: true)
            table.column(self.password)
        }
        do {
            try self.database.run(createTable)
            print("Table Created")
        } catch {
            print(error)
        }
        
        //WRITING INTO THE DATABASE
        let tempName = "Demostracion"
        let tempEmail = "demo@demo.mx"
        let tempPassword = "1q2w3e"
        let insertUser = self.usersTable.insert(self.name <- tempName, self.email <- tempEmail, self.password <- tempPassword)
        do {
            try self.database.run(insertUser)
            print("User Inserted")
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        let txtEmail = txt_Email.text
        let txtPassword = txt_Password.text
        var userFound = false
        
        //READING DATABASE
        do {
            let users = try self.database.prepare(self.usersTable)
            for user in users {
                print(user[self.email])
                if(user[self.email] == txtEmail && user[self.password] == txtPassword){
                    
            
                    //Storing  current username
                    defaults.set(user[self.email], forKey: "currentUsername")
                    defaults.set(user[self.password], forKey: "currentPassword")
                    defaults.set(user[self.name], forKey: "currentName")
                    
                    
                    userFound = true
                    //MOVING TO ANOTHER VIEWCONTROLLER
                    let vc = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
            }
            if(!userFound){
                // Create new Alert
                let dialogMessage = UIAlertController(title: "Error", message: "User Not Found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Try Again", style: .default)
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
            }
        } catch {
            print(error)
        }
    }
}

