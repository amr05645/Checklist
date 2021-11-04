//
//  ViewController.swift
//  CheckLists
//
//  Created by Amr on 10/27/21.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
	
	var items = [ChecklistItem]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.prefersLargeTitles = true
		// Load items
		loadChecklistItems()
	}
	
	func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
		let label = cell.viewWithTag(1001) as! UILabel
		if item.checked {
			label.text = "✓"
		} else {
			label.text = ""
		}
		saveChecklistItems()
	}
	
	func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
		let label = cell.viewWithTag(1000) as! UILabel
		label.text = item.text
	}
	
	// MARK:- Table View Data Source
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
		let item = items[indexPath.row]
		configureCheckmark(for: cell, with: item)
		configureText(for: cell, with: item)
		return cell
	}
	
	// MARK:- Table View Delegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) {
			let item = items[indexPath.row]
			item.toggleChecked()
			configureCheckmark(for: cell, with: item)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		items.remove(at: indexPath.row)
		let indexPaths = [indexPath]
		tableView.deleteRows(at: indexPaths, with: .automatic)
		saveChecklistItems()
	}
	
	// MARK:- Add Item ViewController Delegates
	func itemDetailViewController(_ controller: ItemDetailViewController, didFinishingAdding item: ChecklistItem) {
		let newRowIndex = items.count
		items.append(item)
		let indexPath = IndexPath(row: newRowIndex, section: 0)
		let indexPaths = [indexPath]
		tableView.insertRows(at: indexPaths, with: .automatic)
		navigationController?.popViewController(animated:true)
	}
	
	func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
		navigationController?.popViewController(animated:true)
		saveChecklistItems()
	}
	
	func itemDetailViewController(_ controller: ItemDetailViewController, didFinishingEditing item: ChecklistItem) {
		if let index = items.index(of: item) {
		let indexPath = IndexPath(row: index, section: 0)
			if let cell = tableView.cellForRow(at: indexPath) {
					configureText(for: cell, with: item)
				}
		}
		navigationController?.popViewController(animated:true)
		saveChecklistItems()
	}
	
	// MARK:- Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// 1
		if segue.identifier == "AddItem" {
			// 2
			let controller = segue.destination as! ItemDetailViewController
			// 3
			controller.delegate = self
		} else if segue.identifier == "EditItem" {
			let controller = segue.destination as! ItemDetailViewController
			controller.delegate = self
			if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
				controller.itemToEdit = items[indexPath.row]
			}
		}
	}
	
	// MARK:- Saving
	func documentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
	func dataFilePath() -> URL {
		return documentsDirectory().appendingPathComponent("Checklists.plist")
	}
	
	func saveChecklistItems() {
		// 1
		let encoder = PropertyListEncoder()
		// 2
		do {
			// 3
			let data = try encoder.encode(items)
			// 4
			try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
		}
		// 5
		catch {
			// 6
			print("Error encoding item array: \(error.localizedDescription)")
		}
	}
	
	func loadChecklistItems() {
		// 1
		let path = dataFilePath()
		//2
		if let data = try? Data(contentsOf: path) {
			// 3
			let decoder = PropertyListDecoder()
			do {
				// 4
				items = try decoder.decode([ChecklistItem].self, from: data)
			}
			catch {
				print("Error decoding item array: \(error.localizedDescription)")
			}
		}
	}
	
}
