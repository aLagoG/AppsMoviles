//
//  LoginViewController.swift
//  AppsMoviles
//
//  Created by Leslie Marjorie Gallegos Salazar on 13/11/17.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelLogin(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func startRegister(_ sender: Any) {
        self.view.removeFromSuperview()
        let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "registerPopUp") as! RegisterViewController
        self.parent?.addChildViewController(popUpVC)
        popUpVC.view.frame = (self.parent?.view.frame)!
        self.parent?.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    
    
    /*/Users/a01169525/Desktop/AppsMoviles/AppsMoviles/LoginViewController.swift
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
