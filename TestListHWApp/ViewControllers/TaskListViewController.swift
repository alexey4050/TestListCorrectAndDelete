//
//  ViewController.swift
//  TestListHWApp
//
//  Created by testing on 25.11.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    @objc
    private func addNewTask(){
        showAlert(with: "New Task", and: "What do you want to do?")
    }
}

// MARK: - Private Methods
private extension TaskListViewController {
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = UIColor(named: "MilkGreen")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    //MARK: - Add New Task
    private func fetchData() {
        StorageManager.shared.fetchData { [unowned self] taskList in
            self.taskList = taskList
            self.tableView.reloadData()
        }
    }
    
    private func showAlert(with title: String, and message: String, initialText: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            StorageManager.shared.saveTask(task) { [weak self] savedTask in
                self?.taskList.append(savedTask)
                self?.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField {
            textField in textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
}
//MARK: - Table View Data Source

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
    }
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, complitionHandler) in
            let task = self?.taskList[indexPath.row]
            if let taskToDelete = task {
                self?.storageManager.deleteTask(taskToDelete)
                self?.taskList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            complitionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            self?.editTask(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func editTask(at indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        showAlert(with: "Edit Task", and: "Update the task", initialText: task.title)
        
        //        { [weak self] newTitle in
        //            task.title = newTitle
        //            self?.storageManager.updateTask(task)
        //            
        //            if let cell = self?.tableView.cellForRow(at: indexPath) {
        //                var content = cell.defaultContentConfiguration()
        //                content.text = newTitle
        //                cell.contentConfiguration = content
        //            }
        //        }  не смог реализовать метод, не уверен в правильности создания func updateTask
    }
}

