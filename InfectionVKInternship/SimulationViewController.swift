//
//  SimulationViewController.swift
//  InfectionVKInternship
//
//  Created by Егор Жуков on 25.03.2024.
//

import UIKit

class SimulationViewController: UIViewController {
    var groupSize: Int = 100
    var infectionFactor: Int = 3
    var period: Double = 1.0
    
    var people: [Bool] = []
    
    var itemsPerRow = 6
    
    private var infectionTimer: Timer?

    private func startInfectionTimer() {
        infectionTimer = Timer.scheduledTimer(timeInterval: period, target: self, selector: #selector(updateInfection), userInfo: nil, repeats: true)
    }
    
    private lazy var infectedCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.text = "0"
        return label
    }()

    private lazy var healthyCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .green
        label.text = "\(groupSize)"
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: "PersonCell")
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    @objc private func updateInfection() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var tempPeople = self.people
            var newInfections = [Int]()

            for index in 0..<self.people.count where self.people[index] {
                let neighbors = self.getNeighbors(for: index, in: self.people.count, itemsPerRow: self.itemsPerRow)
                    .filter { $0 < tempPeople.count && !tempPeople[$0] }

                if neighbors.isEmpty {
                    continue
                }

                let infectionsCount = min(neighbors.count, Int.random(in: 1...self.infectionFactor))
                let selectedNeighbors = neighbors.shuffled().prefix(infectionsCount)

                for neighborIndex in selectedNeighbors {
                    tempPeople[neighborIndex] = true
                    newInfections.append(neighborIndex)
                }
            }

            DispatchQueue.main.async {
                let infectedCount = self.people.filter { $0 }.count
                let healthyCount = self.people.count - infectedCount
                self.infectedCountLabel.text = "\(infectedCount)"
                self.healthyCountLabel.text = "\(healthyCount)"
                
                if healthyCount == 0 {
                    self.infectionTimer?.invalidate()
                    self.infectionTimer = nil
                }
                
                self.people = tempPeople

                let indexPaths = newInfections.map { IndexPath(item: $0, section: 0) }
                self.collectionView.reloadItems(at: indexPaths)
            }
        }
    }

    private func getNeighbors(for index: Int, in total: Int, itemsPerRow: Int) -> [Int] {
        var neighbors = [Int]()

        let row = index / itemsPerRow
        let column = index % itemsPerRow
        let lastRowFirstIndex = (total / itemsPerRow) * itemsPerRow // Индекс первого элемента в последнем ряду

        if row > 0 {
            neighbors.append(index - itemsPerRow)
            if column > 0 {
                neighbors.append(index - itemsPerRow - 1)
            }
            if column < itemsPerRow - 1 {
                neighbors.append(index - itemsPerRow + 1)
            }
        }

        // Проверяем, есть ли соседи снизу, учитывая неполный последний ряд
        if index + itemsPerRow < total || (row < (total / itemsPerRow) && index >= lastRowFirstIndex) {
            neighbors.append(index + itemsPerRow)
            if column > 0 && index + itemsPerRow - 1 < total {
                neighbors.append(index + itemsPerRow - 1)
            }
            if column < itemsPerRow - 1 && index + itemsPerRow + 1 < total {
                neighbors.append(index + itemsPerRow + 1)
            }
        }

        if column > 0 {
            neighbors.append(index - 1)
        }
        if column < itemsPerRow - 1 {
            neighbors.append(index + 1)
        }
        
        neighbors = neighbors.filter { $0 >= 0 && $0 < total }

        return neighbors
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupConstraints()
        
        people = Array(repeating: false, count: groupSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startInfectionTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        infectionTimer?.invalidate()
        infectionTimer = nil
    }
    
    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(infectedCountLabel)
        view.addSubview(healthyCountLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            infectedCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            infectedCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            healthyCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            healthyCountLabel.leadingAnchor.constraint(equalTo: infectedCountLabel.trailingAnchor, constant: 20),
            
            collectionView.topAnchor.constraint(equalTo: healthyCountLabel.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SimulationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        cell.configure(with: people[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !people[indexPath.item] {
            people[indexPath.item] = true
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

class PersonCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .green
    }
    
    func configure(with isInfected: Bool) {
        backgroundColor = isInfected ? .red : .green
    }
}
