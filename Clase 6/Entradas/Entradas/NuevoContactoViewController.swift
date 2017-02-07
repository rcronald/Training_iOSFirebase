//
//  NuevoContactoViewController.swift
//  Entradas
//
//  Created by academia moviles on 6/02/17.
//  Copyright © 2017 Gustavo Aceredo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class NuevoContactoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imagenContacto: UIImageView!
    @IBOutlet weak var nombreContacto: UITextField!
    @IBOutlet weak var apellidosContacto: UITextField!
    @IBOutlet weak var direccionContacto: UITextField!
    @IBOutlet weak var fechaNacimiento: UIDatePicker!
    @IBOutlet weak var sexoContacto: UISegmentedControl!
    
    var nombres:String!
    var apellidos:String!
    var direccion:String!
    var fechaNac:String!
    var sexo:String!
    
    var user = FIRAuth.auth()?.currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Esto hace que el imageview se comporte como boton
        self.imagenContacto.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                             action: #selector(SeleccionoImagen)))
        
        self.imagenContacto.isUserInteractionEnabled = true
        self.imagenContacto.contentMode = .scaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cambiarFecha(_ sender: Any) {
        fechaNac = String(describing: fechaNacimiento.date)
        
        print(fechaNac)
    }
    
    @IBAction func cambiarSexo(_ sender: Any) {
        switch sexoContacto.selectedSegmentIndex {
        case 0:
            sexo = "Hombre"
        case 1:
            sexo = "Mujer"
        default:
            sexo = "Otro"
        }
        print(sexo)
    }
    
    @IBAction func guardarContacto(_ sender: Any) {
        
        nombres = nombreContacto.text
        apellidos = apellidosContacto.text
        direccion = direccionContacto.text
        
        let ImagenEnviar = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(ImagenEnviar).png")

        if let uploadData = UIImagePNGRepresentation(self.imagenContacto.image!) {
            
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let valores = ["nombre": self.nombres , "apellido" : self.apellidos, "direccion": self.direccion, "fechaNacimiento": self.fechaNac, "sexo": self.sexo, "urlImagen" : profileImageUrl]
                    self.GuardoDatos((self.user?.uid)!, values: valores as [String : AnyObject])
                    
                }
                print("Se guardaron los datos")
            })
        }
    }
    
    
    func GuardoDatos(_ uid: String, values: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference(fromURL: "https://entradas-demo.firebaseio.com/")
        
        ref.child("user_profiles/\(user!.uid)").child("/Contactos/").setValue(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                return
            }
        })
    }
    
    
    
    func SeleccionoImagen() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imagenContacto.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagenContacto.image = image
        } else {
            imagenContacto.image = nil
        }
        
    }
    
}
