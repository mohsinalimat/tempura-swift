//
//  MarkItem.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import Katana

struct AddItem: AppAction {
  var text: String
  
  func updatedState(currentState: inout AppState) {
    let newItem = Todo(text: self.text)
    currentState.items.insert(newItem, at: 0)
  }
}

struct EditItem: AppAction {
  var id: String
  var text: String
  
  func updatedState(currentState: inout AppState) {
    guard let index = currentState.items.index(where: { $0.id == self.id }) else { return }
    currentState.items[index].text = self.text
  }
}

struct DeleteItem: AppAction {
  var id: String
  
  func updatedState(currentState: inout AppState) {
    guard let index = currentState.items.index(where: { $0.id == self.id }) else { return }
    currentState.items.remove(at: index)
  }
}

struct DeleteArchivedItems: AppAction {
  
  func updatedState(currentState: inout AppState) {
    currentState.items = currentState.items.filter { !$0.archived }
  }
}

struct ToggleItem: AppAction {
  var itemID: String
  
  func updatedState(currentState: inout AppState) {
    let position = currentState.items.index { $0.id == itemID }
    guard let index = position else { return }
    currentState.items[index].completed = !currentState.items[index].completed
  }
}

struct ToggleArchiveItems: AppAction {
  var ids: [String]
  var archived: Bool
  
  init(ids: [String], archived: Bool = true) {
    self.ids = ids
    self.archived = archived
  }
  
  func updatedState(currentState: inout AppState) {
    let positions = ids.flatMap { [currentState] id -> Int? in
      currentState.items.index { $0.id == id }
    }
    positions.forEach {
      currentState.items[$0].archived = archived
      if !archived {
        currentState.items[$0].completed = false
      }
    }
  }
}
