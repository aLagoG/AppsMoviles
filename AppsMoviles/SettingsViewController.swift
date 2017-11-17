//
//  SettingsViewController.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 14/09/17.
//
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate{

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var notificationsSw: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profilePic.layer.cornerRadius = profilePic.frame.height/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.image = UIImage.fontAwesomeIcon(name: .cog, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        tabBarItem.selectedImage = tabBarItem.image
    }
    
    
    //Funciones triggereadas por interacción con el usuario
    @IBAction func turnNotifications(_ sender: Any) {

    }
    
    
    @IBAction func changeProfilePic(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        let alert = UIAlertController(title: "Cambiar foto de perfil", message: "", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Elegir de la galería", style: .default, handler: {
            action1 in
            print("De la galería")
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(picker, animated: true, completion: nil)
        })
        let action2 = UIAlertAction(title: "Tomar una foto con la cámara", style: .default, handler:{
            action2 in
            print("De la cámara")
            if (UIImagePickerController.isSourceTypeAvailable(.camera)){
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true, completion: nil)
            }else{
                self.noCamera()
            }
        })
        let action3 = UIAlertAction(title: "Cancelar", style: .default) { action3 in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //Funciones del ImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePic.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Funciones extras
    func noCamera(){
        let alert = UIAlertController(title: "No camera", message: "There was no camera found", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func startLogin(_ sender: Any) {
        let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "loginPopUp") as! LoginViewController
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    //Funciones para envio de e-mail
    
    @IBAction func enviarCorreo(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else{
            self.showSendMailErrorAlert()
        }
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        //mailComposerVC.setToRecipients([RegisterViewController.register(RegisterViewController)])
        mailComposerVC.setSubject("Resumen semanal - It's Time!")
        let goals = Store.getGoals()
        var tohtml = ""
        for goal in goals.filter({gl in !gl.finished && gl.tasks.count > 0}){
            tohtml += "<p><strong>\(goal.name)</strong>: \(goal.countTasksDone()) de \(goal.tasks.count) tareas hechas</p> <ul>"
            for task in goal.tasks{
                tohtml += "<li>\(task.name)</li>"
            }
            tohtml += "</ul>"
        }
        mailComposerVC.setMessageBody("<p>¡Hola! Aquí tienes el resumen de tu semana.</p> \(tohtml) <p>¡A trabajar!</p>", isHTML: true)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "No se puede enviar e-mail", message: "Tu dispositvo no esta configurado para enviar mensajes.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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
