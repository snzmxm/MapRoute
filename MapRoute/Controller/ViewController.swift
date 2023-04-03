//
//  ViewController.swift
//  MapRoute
//
//  Created by Maxim Bogdanov on 03.04.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    //MARK: - Creating Elements

    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "delete"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    let addAdressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addAdress"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var annotationArray = [MKPointAnnotation]()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupViews()
        setConstraints()

        addAdressButton.addTarget(self, action: #selector(addAdressButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
    }
    //MARK: - Hierarchy View
    func setupViews() {
        view.addSubview(mapView)
        mapView.addSubview(addAdressButton)
        mapView.addSubview(deleteButton)
        mapView.addSubview(routeButton)
    }
    //MARK: - Tapped
    @objc func addAdressButtonTapped() {
        alertAddAdress(title: "Добавить", placeholder: "Введите адрес") { [self] (text) in
            setupPlacemark(adressPlace: text)
        }

    }

    @objc func deleteButtonTapped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationArray = [MKPointAnnotation()]
        routeButton.isHidden = true
        deleteButton.isHidden = true
    }

    @objc func routeButtonTapped() {
        for index in 0...annotationArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationArray[index].coordinate, destinationCoordinate: annotationArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationArray, animated: true)
    }
    //MARK: - setupPlacemark
    private func setupPlacemark(adressPlace: String) {

        let geocder = CLGeocoder()
        geocder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in

            if let error = error {
                print(error)
                alertError(title: "Ошибка", message: "Сервер недоступен. Попробуйте добавить адрес еще раз")
                return
            }

            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first

            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate

            annotationArray.append(annotation)

            if annotationArray.count > 2 {
                routeButton.isHidden = false
                deleteButton.isHidden = false
            }

            mapView.showAnnotations(annotationArray, animated: true)
        }
    }
    //MARK: - createDirectionRequest
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true

        let diraction = MKDirections(request: request)
        diraction.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }

            guard let responce = responce else {
                self.alertError(title: "Ошибка", message: "Маршрут недоступен")
                return
            }

            var minRoute = responce.routes[0]
            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }

            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}
//MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}
//MARK: - setConstraints
extension ViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 70),
            addAdressButton.widthAnchor.constraint(equalToConstant: 140)
        ])

        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50),
            routeButton.heightAnchor.constraint(equalToConstant: 70),
            routeButton.widthAnchor.constraint(equalToConstant: 140)
        ])

        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            deleteButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50),
            deleteButton.heightAnchor.constraint(equalToConstant: 70),
            deleteButton.widthAnchor.constraint(equalToConstant: 140)
        ])
    }
}
