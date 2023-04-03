//
//  Alert.swift
//  MapRoute
//
//  Created by Maxim Bogdanov on 03.04.2023.
//

import UIKit

extension UIViewController {
    func alertAddAdress(title: String, placeholder: String, complitionHandler: @escaping (String) -> Void) {

        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in

            let textFieldText = alertController.textFields?.first
            guard let text = textFieldText?.text else { return }
            complitionHandler(text)
        }

        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }

        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in
        }

        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)

        present(alertController, animated: true, completion: nil)
    }

    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in
        }

        alertController.addAction(alertOk)
        present(alertController, animated: true, completion: nil)
    }
}
