//
//  TodoCollectionViewCell.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import UIKit
import Tempura
import PinLayout

public protocol SizeableCell: ModellableView {
  static func size(for model: VM) -> CGSize
}

class TodoCell: UICollectionViewCell, ConfigurableCell, SizeableCell {
  
  static var identifierForReuse: String = "TodoCell"
  
  var label: UILabel = UILabel()
  var checkButton: UIButton = UIButton(type: .custom)
  var toggleButton: UIButton = UIButton(type: .custom)
  var editButton: UIButton = UIButton(type: .custom)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    self.checkButton.isUserInteractionEnabled = false
    self.toggleButton.on(.touchUpInside) { [unowned self] _ in
      guard let model = self.model else { return }
      self.didToggle?(model.identifier)
    }
    self.editButton.on(.touchUpInside) { [unowned self] _ in
      guard let model = self.model else { return }
      self.didTapEdit?(model.identifier)
    }
    self.addSubview(self.editButton)
    self.addSubview(self.toggleButton)
    self.addSubview(self.label)
    self.addSubview(self.checkButton)
  }
  func style() {
    self.backgroundColor = .white
    self.styleCheckButton()
  }
  
  func update(oldModel: TodoCellViewModel?) {
    guard let model = self.model else { return }
    self.styleLabel(archived: model.archived)
    self.label.text = model.todoText
    self.styleCheckButton(on: model.completed)
    self.setNeedsLayout()
  }
  
  // MARK: Interactions
  var didToggle: ((String) -> ())?
  var didTapEdit: ((String) -> ())?
  
  static var paddingHeight: CGFloat = 10
  static var maxTextWidth: CGFloat = 0.80
  override func layoutSubviews() {
    guard let model = self.model else { return }
    self.checkButton.pin.size(30).vCenter().left(26)
    self.label.pin.top().bottom().left().right()
    let textWidth = self.bounds.width * TodoCell.maxTextWidth
    let textHeight = model.todoText.height(constraintedWidth: textWidth, font: UIFont.systemFont(ofSize: 17))
    self.label.pin.right(of: self.checkButton).marginLeft(13).vCenter().width(textWidth).height(textHeight)
    self.toggleButton.pin.left().right(to: self.label.edge.left).top().bottom()
    self.editButton.pin.left(to: self.toggleButton.edge.right).right().top().bottom()
  }
  
  static func size(for model: TodoCellViewModel) -> CGSize {
    let textWidth = UIScreen.main.bounds.width * TodoCell.maxTextWidth
    let textHeight = model.todoText.height(constraintedWidth: textWidth, font: UIFont.systemFont(ofSize: 17))
    
    return CGSize(width: UIScreen.main.bounds.width,
                  height: textHeight + 2 * TodoCell.paddingHeight)
  }
}

// MARK: - Styling
extension TodoCell {
  func styleLabel(archived: Bool = false) {
    self.label.font = UIFont.systemFont(ofSize: 17)
    self.label.numberOfLines = 0
    self.label.textColor = archived ? UIColor.black.withAlphaComponent(0.3) : .black
  }
  func styleCheckButton(on: Bool = false) {
    if on {
      self.checkButton.setImage(UIImage(named: "checkOn"), for: .normal)
      self.checkButton.setImage(UIImage(named: "checkOff"), for: .highlighted)
    } else {
      self.checkButton.setImage(UIImage(named: "checkOff"), for: .normal)
      self.checkButton.setImage(UIImage(named: "checkOn"), for: .highlighted)
    }
  }
}

struct TodoCellViewModel: ViewModel, Hashable {
  var todoText: String = ""
  var completed: Bool = false
  var archived: Bool = false
  var identifier: String
  
  var hashValue: Int {
    return identifier.hashValue
  }
  
  static func == (l: TodoCellViewModel, r: TodoCellViewModel) -> Bool {
    if l.identifier != r.identifier { return false }
    if l.todoText != r.todoText { return false }
    if l.completed != r.completed { return false }
    if l.archived != r.archived { return false }
    return true
  }
  
  init(todo: Todo) {
    self.identifier = todo.id
    self.todoText = todo.text
    self.completed = todo.completed
    self.archived = todo.archived
  }
}

extension String {
  func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.text = self
    label.font = font
    label.sizeToFit()
    
    return label.frame.height
  }
}
