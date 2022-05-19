//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        guard let task = StorageManager.shared.fetchData() else { return }
        taskList = task
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAlert(for: .save, with: "New Task", and: "What do you want to do?")
    }
    
    private func showAlert(for action: Action, with title: String, and message: String, indexPath: IndexPath? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = saveAction(alert: alert, for: action, indexPath: indexPath)
        setTextField(alert: alert, for: action, indexPath: indexPath)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // MARK: - Set UI Alert action
    private func saveAction(alert: UIAlertController, for action: Action, indexPath: IndexPath?) -> UIAlertAction {
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            switch action {
            case .save:
                guard let newTask = StorageManager.shared.save(title: task) else { return }
                taskList.append(newTask)
                tableView.insertRows(at: [IndexPath(row: taskList.count - 1 , section: 0)], with: .automatic)
            case .edit:
                guard let indexPath = indexPath else { return }
                StorageManager.shared.edit(self.taskList[indexPath.row], newName: task)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        return saveAction
    }
    
    // MARK: - Set Text Field
    private func setTextField(alert: UIAlertController, for action: Action, indexPath: IndexPath?) {
        switch action {
        case .save:
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        case .edit:
            alert.addTextField { textField in
                guard let indexPath = indexPath else { return }
                textField.placeholder = self.taskList[indexPath.row].title
                textField.text = self.taskList[indexPath.row].title
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            StorageManager.shared.delete(taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(for: .edit, with: "Change Task", and: "", indexPath: indexPath)
    }
}

