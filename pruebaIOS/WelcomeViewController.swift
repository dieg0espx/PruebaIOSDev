//
//  WelcomeViewController.swift
//  pruebaIOS
//
//  Created by DIEGO ESPINOSA on 2023-01-20.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var lb_currentUser: UILabel!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lb_currentUser.text = (defaults.object(forKey:"currentName") as! String)
    }
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        print("Login out ...")
        defaults.set("", forKey: "currentUsername")
        defaults.set("", forKey: "currentPassword")
        //MOVING TO ANOTHER VIEWCONTROLLER
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
}
