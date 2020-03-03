//
//  MainViewController.swift
//  OpenMask
//
//  Created by House on 2020/2/6.
//  Copyright © 2020 haohsu. All rights reserved.
//

import UIKit
import GoogleMaps

class MainViewController: BaseViewController {
    
    
    let MapInitLevel: Float = 7.0
    let MapNormalLevel: Float = 16.0
    let MapMarkerLevel: Float = 14.0
    
    let MarkerColor: UIColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1)
    let MarkerSelectedColor: UIColor = .orange
    
    var MarkerInfoHeight: CGFloat {
        get {
            var height: CGFloat = 266
            if self.view.safeAreaInsets.bottom > 0 {
                height += 18
            }
            return height
        }
    }
    
    @IBOutlet weak var ivLocation: UIImageView!

    @IBOutlet weak var map: GMSMapView!
    
    @IBOutlet weak var btnMyLocation: UIButton!
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var vSearch: UIView!
    
    @IBOutlet weak var tfSearch: UITextField!
    
    @IBOutlet weak var vInfo: UIView!
    
    @IBOutlet weak var vSearchResult: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var infoViewController: InfoViewController?
    
    var location: CLLocation? {
        didSet {
            self.map.isMyLocationEnabled = location != nil
        }
    }
    
    var markers: [Marker] = Array()
    
    var result: [Marker] = Array()
    
    var selectedMarker: Marker? {
        didSet {
            if let marker = self.selectedMarker {
                self.tfSearch.text = marker.address
                let camera = GMSCameraPosition.camera(withLatitude: marker.latitude, longitude: marker.longitude, zoom: self.map.camera.zoom)
                self.map.animate(to: camera)
                if let viewController = self.infoViewController {
                    viewController.marker = marker
                }
                showMarkerInfo()
            }
            else {
                self.tfSearch.text = nil
                hideMarkerInfo()
            }
            refreshInterface()
            refreshMapMarker()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMapView()
        initMarkerData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshInterface()
    }
    
    override func registerNotification() {
        super.registerNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshLocation), name: AppNotification.locationUpdate.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func unregisterNotification(){
        super.unregisterNotification()
        NotificationCenter.default.removeObserver(self, name: AppNotification.locationUpdate.name, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func initInterface() {
        super.initInterface()
        
        self.btnMyLocation.layer.cornerRadius = self.btnMyLocation.frame.width/2
        self.btnMyLocation.addShadoow()
        
        self.vInfo.addShadoow()
        
        self.vSearch.layer.cornerRadius = 4
        self.vSearch.layer.borderColor = UIColor(named: "ColorLightGray")?.cgColor
        self.vSearch.addShadoow()
        self.tfSearch.attributedPlaceholder = NSAttributedString(string: localizedString("hint_search"), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "ColorGray")!])
        self.tfSearch.delegate = self
        self.tfSearch.addTarget(self, action: #selector(onTextEditingChange(sender:)), for: .editingChanged)
        
        self.vInfo.frame.origin.y = UIScreen.main.bounds.height
        
        self.infoViewController = self.children[0] as? InfoViewController
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onMarkerInfoPan(sender:)))
        vInfo.addGestureRecognizer(gestureRecognizer)
        
        self.tableView.register(UINib(nibName: "MarkerViewCell", bundle: nil), forCellReuseIdentifier: "MarkerViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    private func initMapView() {
        self.map.camera = GMSCameraPosition.camera(withLatitude: 23.5832, longitude: 120.5825, zoom: MapInitLevel)
        // set style
        do {
          // Set the map style by passing the URL of the local file.
          if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
            self.map.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          } else {
            NSLog("Unable to find style.json")
          }
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        // set delegate
        self.map.delegate = self
    }
    
    private func initMarkerData() {
        ServerUtils.request(url: "https://mask-data-farmer.herokuapp.com/restful/getMasks", method: .get, params: nil) { (success: Bool, message: String, data: [[String: Any]]?) in
            self.markers.removeAll()
            if let _markers = data {
                for _marker in _markers {
                    let marker = Marker(data: _marker)
                    if !marker.isValid {
                        continue
                    }
                    self.markers.append(marker)
                }
            }
            self.refreshMapMarker()
        }
    }
    
    private func refreshInterface() {
        if self.tfSearch.isEditing {
            self.btnClose.isHidden = false
            self.ivLocation.isHidden = true
            self.vSearchResult.isHidden = false
            self.vSearch.layer.shadowOpacity = 0
            self.vSearch.layer.borderWidth = 1
        }
        else if self.selectedMarker != nil {
            self.btnClose.isHidden = false
            self.ivLocation.isHidden = true
            self.vSearchResult.isHidden = true
            self.vSearch.layer.shadowOpacity = 0.8
            self.vSearch.layer.borderWidth = 0
        }
        else {
            self.btnClose.isHidden = true
            self.ivLocation.isHidden = false
            self.vSearchResult.isHidden = true
            self.vSearch.layer.shadowOpacity = 0.8
            self.vSearch.layer.borderWidth = 0
        }
    }
    
    private func refreshMapMarker() {
        self.map.clear()

        let bounds = GMSCoordinateBounds(region: self.map.projection.visibleRegion())
        
        for data in self.markers {
            let selected = data == self.selectedMarker
            if !selected && self.map.camera.zoom < MapMarkerLevel {
                continue
            }
            
            let position = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
            if !bounds.contains(position) {
                continue
            }
            
            let marker = GMSMarker(position: position)
            marker.icon = GMSMarker.markerImage(with: selected ? MarkerSelectedColor : MarkerColor)
            marker.map = self.map
            
        }
    }
    
    @objc private func refreshLocation() {
        let currentLocation = self.appDelegate.location
        if let coordinate = currentLocation?.coordinate , self.location == nil {
            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: MapNormalLevel)
            self.map.animate(to: camera)
        }
        self.location = currentLocation
    }
    
    private func hideMarkerInfo() {
        let offset = UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.3) {
            self.vInfo.frame.origin.y = offset
            self.btnMyLocation.frame.origin.y = offset - self.btnMyLocation.frame.height*2
        }
    }
    
    private func showMarkerInfo() {
        let offset = UIScreen.main.bounds.height - MarkerInfoHeight
        UIView.animate(withDuration: 0.3) {
            self.vInfo.frame.origin.y = offset
            self.btnMyLocation.frame.origin.y = offset - self.btnMyLocation.frame.height*2
        }
    }

    @IBAction func onMyLocationClick(_ sender: Any) {
        self.location = nil
        refreshLocation()
    }
    
    @IBAction func onCloseClick(_ sender: Any) {
        
        self.tfSearch.resignFirstResponder()
        self.selectedMarker = nil
    }
    
    @objc func onMarkerInfoPan(sender: UIPanGestureRecognizer) {
        var translationY = sender.translation(in: view).y
        switch sender.state {
        case .changed:
            if translationY < 0 {
                translationY = 0
            }
            let offset = UIScreen.main.bounds.height - MarkerInfoHeight + translationY
            self.vInfo.frame.origin.y = offset
            self.btnMyLocation.frame.origin.y = offset - self.btnMyLocation.frame.height*2
        case .ended:
            if translationY < (MarkerInfoHeight * 0.5) {
                showMarkerInfo()
            } else {
                self.selectedMarker = nil
            }
        default:
            break
        }
    }
    
    @objc func onTextEditingChange(sender: UITextField) {
        self.result.removeAll()
        if let key = sender.text {
            for marker in self.markers {
                if marker.title.contains(key) || marker.address.contains(key) {
                    self.result.append(marker)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    @objc func onKeyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let height = UIScreen.main.bounds.height - self.tableView.frame.origin.y - keyboardHeight
            self.tableView.frame.size.height = height
        }
    }
}

extension MainViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        refreshMapMarker()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        for _marker in self.markers {
            if _marker.latitude == marker.position.latitude && _marker.longitude == marker.position.longitude {
                self.selectedMarker = _marker
                break
            }
        }
        return false
    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        refreshInterface()
        onTextEditingChange(sender: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        refreshInterface()
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarkerViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarkerViewCell", for: indexPath) as! MarkerViewCell
        
        let marker = self.result[indexPath.row]
        cell.lbTitle.text = marker.title
        cell.lbAddress.text = marker.address
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.tfSearch.resignFirstResponder()
        self.selectedMarker = self.result[indexPath.row]
    }
}
