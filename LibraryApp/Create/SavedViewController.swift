import UIKit
import CoreData

class SavedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var create_iView:UIImageView!
    @IBOutlet weak var create_edText:UITextField!
    @IBOutlet weak var create_edPrice:UITextField!
    @IBOutlet weak var create_buSave:UIButton!
    
    //Selected Variables
    var selectedName = ""
    var selectedId :UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load Data
        if(selectedName != ""){
            create_buSave.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchContext = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
            let stringId = selectedId?.uuidString
            fetchContext.predicate = NSPredicate(format: "id=%@", stringId!)
            fetchContext.returnsObjectsAsFaults = false
            
            //Do Coding
            do{
                let result = try context.fetch(fetchContext)
                if(result.count > 0){
                    for results in result as! [NSManagedObject]{
                        if let name = results.value(forKey: "book_name") as? String{
                            create_edText.text = name
                        }
                        if let price = results.value(forKey: "price") as? String{
                            create_edPrice.text = String(price)
                        }
                        if let image = results.value(forKey: "photo") as? Data{
                            let photo = UIImage(data: image)
                            create_iView.image = photo
                        }
                    }
                }
            }catch{
                print("Error For Upload Data")
            }
        }else{
            selectedName = ""
        }
        
        //Gesture Recognizers For Select Image
        let gestureReconizers = UITapGestureRecognizer(target: self, action: #selector(onClickImage))
        create_iView.addGestureRecognizer(gestureReconizers)
        create_iView.isUserInteractionEnabled = true
    }
    //Button Save
    @IBAction func create_buSave(_ sender:Any){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context)
        
        //Set Value Into Database
        newBook.setValue(create_edText.text!, forKey: "book_name")
        newBook.setValue(create_edPrice.text!, forKey: "price")
        newBook.setValue(UUID(), forKey: "id")
        
        //Save Image
        let imageData = create_iView.image?.jpegData(compressionQuality: 0.5)
        newBook.setValue(imageData, forKey: "photo")
        
        do{
            try context.save()
            create_edText.text = ""
            create_edPrice.text = ""
            create_iView.image = UIImage(named: "select_image")
            showToast(message: "Saved Complete")
            
        }catch{
            showToast(message: "Save Failed")
        }
        //Notifcation Center
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        navigationController?.popViewController(animated: true)
        //Button Save
    }
    
    //On Click Image
    @objc func onClickImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        create_iView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    //Show Toast Function
    func showToast(message:String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.layer.cornerRadius = 14
        alert.view.alpha = 1.4
        alert.view.backgroundColor = .white
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7){
            alert.dismiss(animated: true)
        }
    }
}
