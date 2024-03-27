//
//  ViewController.swift
//  InfectionVKInternship
//
//  Created by Егор Жуков on 25.03.2024.
//

import UIKit

class ParametersViewController: UIViewController {
    
    private lazy var groupSizeTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Group Size"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var infectionFactorTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Infection Factor"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var periodTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Period (T)"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var startSimulationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start Simulation", for: .normal)
        button.addTarget(self, action: #selector(startSimulation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(groupSizeTextField)
        view.addSubview(infectionFactorTextField)
        view.addSubview(periodTextField)
        view.addSubview(startSimulationButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            groupSizeTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            groupSizeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            groupSizeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infectionFactorTextField.topAnchor.constraint(equalTo: groupSizeTextField.bottomAnchor, constant: 20),
            infectionFactorTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infectionFactorTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            periodTextField.topAnchor.constraint(equalTo: infectionFactorTextField.bottomAnchor, constant: 20),
            periodTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            periodTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startSimulationButton.topAnchor.constraint(equalTo: periodTextField.bottomAnchor, constant: 40),
            startSimulationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func startSimulation() {
        guard let groupSizeText = groupSizeTextField.text, let groupSize = Int(groupSizeText),
              let infectionFactorText = infectionFactorTextField.text, let infectionFactor = Int(infectionFactorText),
              let periodText = periodTextField.text, let period = Double(periodText) else {
            showAlert(message: "Please enter valid values for all fields.")
            return
        }
        
        let simulationViewController = SimulationViewController()
        simulationViewController.groupSize = groupSize
        simulationViewController.infectionFactor = infectionFactor
        simulationViewController.period = period
        navigationController?.pushViewController(simulationViewController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

