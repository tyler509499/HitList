//
//  ViewController.swift
//  HitList
//
//  Created by Galkov Nikita on 14.03.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var toDoList: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToDoList")
        
        do {
            toDoList = try managedContext.fetch(fetchRequest)
        } catch  let error as NSError{
            print("Can not save \(error)")
        }
    }

    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "Новое имя", message: "Добавте новое имя", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] (action) in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            self?.save(name: nameToSave)
            self?.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ToDoList", in: managedContext)!
        let oneToDo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        oneToDo.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            toDoList.append(oneToDo)
        } catch let error as NSError {
            print("Can not save \(error), \(error.userInfo)")
        }
    }

}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneToDo = toDoList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = oneToDo.value(forKey: "name") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
      return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       if editingStyle == .delete  {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(toDoList[indexPath.row] as NSManagedObject)
        toDoList.remove(at: indexPath.row)
                do {
                    try managedContext.save()
                } catch let error {
                    print("error : \(error)")
                }
        self.tableView.deleteRows(at: [indexPath], with: .fade)
       
        }
}


}


