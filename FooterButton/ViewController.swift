//
//  ViewController.swift
//  FooterButton
//
//  Created by Daniel Graef on 3/27/19.
//  Copyright © 2019 MoneySuperMarket. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    class TableView: UITableView {
        
        var willReload: (() -> Void)?
        var layoutPass: (() -> Void)?
        
        override func reloadData() {
            willReload?()
            super.reloadData()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            layoutPass?()
        }
        
    }
    
    private var tableView: TableView!
    
    private var pinnedFooterView: UIView!
    private var tableFooterView: UIView!
    
    private var pinFooterConstraints = [NSLayoutConstraint]()
    private var numberOfRows = 1
    private var layoutRequired = true
    private var shouldPin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pinUnpin))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(generateNext))
        createTableView()
        createPinnedFooterView()
        createTableFooterView()
    }
    
    private func createTableView() {
        tableView = TableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layoutPass = styleFooter
        tableView.willReload = willReloadTableView
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    private func createPinnedFooterView() {
        pinnedFooterView = UIView()
        pinnedFooterView.translatesAutoresizingMaskIntoConstraints = false
        pinnedFooterView.backgroundColor = .purple
        setHeight(150, view: pinnedFooterView)
        
        pinFooterConstraints.append(contentsOf: [
            pinnedFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pinnedFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pinnedFooterView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }
    
    private func createTableFooterView() {
        tableFooterView = UIView()
        tableFooterView.backgroundColor = .yellow
        setHeight(150, view: tableFooterView)
    }
    
    private func setHeight(_ height: CGFloat, view: UIView) {
        let heightConstraint = NSLayoutConstraint(item: view,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: height)
        heightConstraint.priority = .defaultHigh
        view.addConstraint(heightConstraint)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .red : .blue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell")!
    }
    
}

// Taken from: https://spin.atomicobject.com/2017/08/11/swift-extending-uitableviewcontroller/
private extension ViewController {
    
    func willReloadTableView() {
        layoutRequired = true
    }
    
    func styleFooter() {
        
        guard layoutRequired else { return }
        
        let anchoredFooterInset = UIEdgeInsets(top: 0, left: 0, bottom: pinnedFooterView.bounds.height, right: 0)
        let shouldContentScroll = tableView.contentSize.height > tableView.bounds.size.height - anchoredFooterInset.bottom
        
        // Content scrolls. If pin - view, if not pin, table footer view
        // Content does not
        
        if shouldPin || !shouldPin && shouldContentScroll {
            view.addSubview(pinnedFooterView)
            pinFooterConstraints.forEach({ $0.isActive = true })
            tableView.contentInset = anchoredFooterInset
            tableView.scrollIndicatorInsets = anchoredFooterInset
            tableView.tableFooterView = nil
            tableView.isScrollEnabled = shouldContentScroll
        } else {
            pinFooterConstraints.forEach({ $0.isActive = false })
            pinnedFooterView.removeFromSuperview()
            tableView.contentInset = UIEdgeInsets.zero
            tableView.scrollIndicatorInsets = UIEdgeInsets.zero
            tableView.tableFooterView = tableFooterView
            sizeFooterToFit()
            tableView.isScrollEnabled = true
        }
        
        layoutRequired = false
    }
    
    func sizeHeaderToFit() {
        if let headerView = tableView.tableHeaderView {
            
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            
            tableView.tableHeaderView = headerView
        }
    }
    
    func sizeFooterToFit() {
        if let footerView = tableView.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            
            tableView.tableFooterView = footerView
        }
    }
    
    @objc func generateNext() {
        numberOfRows = (numberOfRows + 1) % 20
        tableView.reloadData()
    }
    
    @objc func pinUnpin() {
        shouldPin = !shouldPin
        tableView.reloadData()
    }
    
}
