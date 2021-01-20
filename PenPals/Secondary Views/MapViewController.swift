//
//  MapViewController.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/20/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    //MARK: - Vars
    var location: CLLocation?
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTitle()
        configureMapView()
        configureLeftBarButton()
        
        
    }
    
    //MARK: - Configurations
    private func configureMapView() {
        
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false)
            
            //add annotation
            mapView.addAnnotation(MapAnnotation(title: "User Location", coordinate: location!.coordinate))
        }
        
        view.addSubview(mapView)
        
    }
    
    private func configureLeftBarButton() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        
    }
    
    private func configureTitle() {
        
    }
    
    //MARK: - Actions
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }

}
