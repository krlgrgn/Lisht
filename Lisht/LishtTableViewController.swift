//
//  LishtTableViewController.swift
//  Lisht
//
//  Created by Karl Grogan on 10/07/2016.
//  Copyright © 2016 Karl Grogan. All rights reserved.
//

import UIKit
import CoreData
import CNPGridMenu

class LishtTableViewController: UITableViewController, UITextFieldDelegate, SwipeCellDelegate, UIGestureRecognizerDelegate,CNPGridMenuDelegate, UIViewControllerTransitioningDelegate {
  
  var items = [Item]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.rowHeight = 66.0
    self.tableView.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 250/255, alpha: 1)
    // Initialize the first table cell as an empty Item.
    self.items.append(Item(text: nil))
    
    // Register the SwipeViewCell as the Cell class/type we want to use to represent our Swipeable cells.
    self.tableView.registerClass(SwipeCell.self, forCellReuseIdentifier: "SwipeCell")
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: SwipeCell
    
    // If the item at the index path has no text then I'm assuming it's the first cell at the top with just the placeholder.
    // I want this cell to not be swipeable. This means it won't be deleted from the table view if someone tries to swipe on it.
    // All the other cells should be swipeable.
    if self.items[indexPath.row].text == nil {
      cell = SwipeCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: nil, disableSwipe: true, cellHeight: self.tableView.rowHeight)
    } else {
      cell = SwipeCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: nil, cellHeight: self.tableView.rowHeight)
    }
    
    cell.textField.placeholder = "Tap to add an item."
    cell.textField.text = self.items[indexPath.row].text    
    cell.textField.delegate = self
    let preferredDescriptor = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    let font = UIFont(name: "Roboto-Light", size: preferredDescriptor.pointSize)
    cell.textField.font = font
    cell.textField.textColor = UIColor.init(red: 87/255, green: 85/255, blue: 91/255, alpha: 1)
    cell.tag = indexPath.row
    cell.delegate = self
    
    return cell
  }
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    let itemIndex = textField.superview!.superview!.superview!.tag
    
    if textField.text != "" {
      if itemIndex > 0 {
        let item = self.items[itemIndex]
        item.text = textField.text
      } else {
        self.items.insert(Item(text: textField.text), atIndex: 1)
      }
    }
    
    self.tableView.reloadData()
    return true
  }
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    print(textField.description)
    return false
  }
  
  // MARK: - SwipeCell delegate method.
  func cellDidCompleteSwipe(cell: SwipeCell) {
    let indexPath = self.tableView.indexPathForCell(cell)
    if cell.swipeDirection == .LeftToRight {
      // Mark the task as completed.
      self.items.removeAtIndex(indexPath!.row)
      self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
    } else if cell.swipeDirection == .RightToLeft {
      // Set up a reminder.
      presentReminderModal()
    }
    
  }
  
  
  func presentReminderModal() {
    let laterToday = CNPGridMenuItem()
    laterToday.icon = UIImage(named: "ic_alarm_48pt")
    laterToday.title = "Later Today";
    
    let tomorrow = CNPGridMenuItem()
    tomorrow.icon = UIImage(named: "ic_wb_sunny_48pt")
    tomorrow.title = "Tomorrow";
    
    let weekend = CNPGridMenuItem()
    weekend.icon = UIImage(named: "ic_weekend_48pt")
    weekend.title = "At The Weekend";
    
    let specificTime = CNPGridMenuItem()
    specificTime.icon = UIImage(named: "ic_date_range_48pt")
    specificTime.title = "Pick A Time";
    
    let gridMenu = CNPGridMenu(menuItems: [laterToday, tomorrow, weekend, specificTime])
    gridMenu.delegate = self
    self.presentGridMenu(gridMenu, animated: true, completion: nil)

  }
  
  func gridMenuDidTapOnBackground(menu: CNPGridMenu!) {
    self.dismissGridMenuAnimated(true, completion: nil)
    self.tableView.reloadData()
  }
  
  func gridMenu(menu: CNPGridMenu!, didTapOnItem item: CNPGridMenuItem!) {
    print(item)
  }
  
  
}