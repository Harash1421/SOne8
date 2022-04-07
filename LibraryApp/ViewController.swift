import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var main_tView:UITableView!
    
    //Variable For Books
    var name = [String]()
    var id = [UUID]()
    
    //Selected Variable
    var chooseName = ""
    var chooseId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        main_tView.delegate = self
        main_tView.dataSource = self
        
        //Get Data
        getData()
        
        //Add Bar Button
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(onClickAdd))
    }
    //On Click Add
    @objc func onClickAdd(){
        chooseName = ""
        self.performSegue(withIdentifier: "toSavedVC", sender: nil)
    }
    
    //View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    //Get Data Function
    @objc func getData(){
        name.removeAll(keepingCapacity: false)
        id.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchContext = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
        fetchContext.returnsObjectsAsFaults = false
        //Do Coding
        do{
            let result = try context.fetch(fetchContext)
            if(result.count > 0){
                for results in result as! [NSManagedObject]{
                    if let name = results.value(forKey: "book_name") as? String{
                        self.name.append(name)
                    }
                    if let id = results.value(forKey: "id") as? UUID{
                        self.id.append(id)
                    }
                    self.main_tView.reloadData()
                }
            }
        }catch{
            print("Error For Upload Data")
        }
        //Get Data
    }
    
    //Table Cell Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = name[indexPath.row]
        return cell
    }
    //Count Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
    }
    
    //Table Did Select Editing
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchContext = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
            let stringId = id[indexPath.row].uuidString
            fetchContext.predicate = NSPredicate(format: "id=%@", stringId)
            fetchContext.returnsObjectsAsFaults = false
            //Do Coding
            do{
                let result = try context.fetch(fetchContext)
                if(result.count > 0){
                    for results in result as! [NSManagedObject]{
                        if let idEdit = results.value(forKey: "id") as? UUID{
                            if(idEdit == id[indexPath.row]){
                                context.delete(results)
                                name.remove(at: indexPath.row)
                                id.remove(at: indexPath.row)
                                self.main_tView.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    print("Error For Dalete This Book")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("Error For Editing")
            }
        }
    }
    
    //Did Selected Rows
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseName = name[indexPath.row]
        chooseId = id[indexPath.row]
        self.performSegue(withIdentifier: "toSavedVC", sender: nil)
    }
    
    //Prepare To Tranclate To Create Screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSavedVC"){
            let destinsion = segue.destination as! SavedViewController
            destinsion.selectedName = chooseName
            destinsion.selectedId = chooseId
        }
    }
    
}

