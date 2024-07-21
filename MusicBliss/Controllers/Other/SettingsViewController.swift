//
//  SettingsViewController.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import UIKit

class SettingsViewController: UIViewController {

  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")

    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Settings"
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = "Foo"
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }


}
