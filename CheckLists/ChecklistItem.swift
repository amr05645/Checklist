//
//  ChecklistItem.swift
//  CheckLists
//
//  Created by Amr on 10/30/21.
//

import Foundation

class ChecklistItem: NSObject, Codable {
	var text = ""
	var checked = false
	
	func toggleChecked() {
		checked = !checked
	}
}
