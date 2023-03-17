//
//  QuotesViewController.swift
//  QuotesConverter
//
//  Created by Taleh Mammadov on 17.03.23.
//

import UIKit
import SocketIO

class QuotesViewController: UIViewController {
    
    let tableView = UITableView()
    var quotes: [Quote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuoteCell.self, forCellReuseIdentifier: "QuoteCell")
        view.addSubview(tableView)
        
        // Connect to the WebSocket
        let manager = SocketManager(socketURL: URL(string: "https://q.investaz.az")!)
        let socket = manager.socket(forNamespace: "/live")
        socket.on(clientEvent: .connect) { _, _ in
            print("Socket connected")
        }
        socket.on(clientEvent: .disconnect) { _, _ in
            print("Socket disconnected")
        }
        socket.on("quotes") { data, _ in
            guard let quotesData = data[0] as? Data else {
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let newQuotes = try decoder.decode([Quote].self, from: quotesData)
                self.quotes = newQuotes
                self.tableView.reloadData()
            } catch {
                print("Error in quotes: \(error.localizedDescription)")
            }
        }
        socket.connect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
}
extension QuotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteCell
        cell.quote = quotes[indexPath.row]
        return cell
    }
}

class QuoteCell: UITableViewCell {
    var quote: Quote? {
        didSet {
            symbolLabel.text = quote?.symbol
            buyPriceLabel.text = "\(quote?.buyPrice ?? 0)"
            sellPriceLabel.text = "\(quote?.sellPrice ?? 0)"
            spreadLabel.text = "\(quote?.spread ?? 0)"
        }
    }
    
    let symbolLabel = UILabel()
    let buyPriceLabel = UILabel()
    let sellPriceLabel = UILabel()
    let spreadLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(symbolLabel)
        contentView.addSubview(buyPriceLabel)
        contentView.addSubview(sellPriceLabel)
        contentView.addSubview(spreadLabel)
        
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        symbolLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        buyPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        buyPriceLabel.leadingAnchor.constraint(equalTo: symbolLabel.trailingAnchor, constant: 16).isActive = true
        buyPriceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        sellPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        sellPriceLabel.leadingAnchor.constraint(equalTo: buyPriceLabel.trailingAnchor, constant: 16).isActive = true
        sellPriceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        spreadLabel.translatesAutoresizingMaskIntoConstraints = false
        spreadLabel.leadingAnchor.constraint(equalTo: sellPriceLabel.trailingAnchor, constant: 16).isActive = true
        spreadLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
