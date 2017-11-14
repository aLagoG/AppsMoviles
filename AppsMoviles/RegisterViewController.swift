//
//  RegisterViewController.swift
//  AppsMoviles
//
//  Created by Leslie Marjorie Gallegos Salazar on 13/11/17.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordCheckTF: UITextField!
    
    let user = UserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        

    }
    func dismissKeyboard(){
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelRegister(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    
    @IBAction func startLogin(_ sender: Any) {
        self.view.removeFromSuperview()
        let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "loginPopUp") as! LoginViewController
        self.parent?.addChildViewController(popUpVC)
        popUpVC.view.frame = (self.parent?.view.frame)!
        self.parent?.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    @IBAction func register(_ sender: Any) {
        let name = nameTF.text
        let email = emailTF.text
        let password = passwordTF.text
        let passwordCheck  = passwordCheckTF.text
        
        if ((name?.isEmpty)! || (email?.isEmpty)! || (password?.isEmpty)! || (passwordCheck?.isEmpty)!){
            displayAlert(message: "Se deben de llenar todos los campos")
            return
        }
        
        if(password != passwordCheck){
            displayAlert(message: "Las contraseñas no coinciden")
            return
        }
        

        user.setValue(name, forKey: "name")
        user.setValue(email, forKey: "email")
        user.setValue(password, forKey: "password")
        user.synchronize()
        
        self.view.removeFromSuperview()
        let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "loginPopUp") as! LoginViewController
        self.parent?.addChildViewController(popUpVC)
        popUpVC.view.frame = (self.parent?.view.frame)!
        self.parent?.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }

    
    func displayAlert(message:  String){
        let alert = UIAlertController(title: "No se puede llevar a cabo el registro", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
