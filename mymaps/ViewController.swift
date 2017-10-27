//
//  ViewController.swift
//  mymaps
//
//  Created by Peter on 2017. 10. 26..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController{
    var pins:[MMPin] = []
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var pinCollectionView: UICollectionView!
    @IBOutlet weak var verticalLineLC: NSLayoutConstraint!
    var locationManager:CLLocationManager?
    @IBAction func myLocationButtonAction(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            let locationManager = CLLocationManager()
            locationManager.requestAlwaysAuthorization()
            self.locationManager = locationManager
            return
        }
        self.mapView.showsUserLocation = true
        if let coordinate = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        }

    }
    var isDrawabled = false{
        didSet{
            self.mapView.isUserInteractionEnabled = !self.isDrawabled
            self.updateDrawButton()
        }
    }
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func drawButtonAction(_ sender: Any) {
        self.isDrawabled = !self.isDrawabled
    }
    func updateDrawButton(){
        self.drawButton.setTitle(self.isDrawabled ? "이동" : "그리기", for: .normal)
    }
    var coordinates:[CLLocationCoordinate2D]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pins = self.loadPins()
        self.pinCollectionView.reloadData()
        self.coordinates = []
        self.updateDrawButton()
    }
    
    func loadPins() -> [MMPin]{
        var pins:[MMPin] = []
        pins.append(MMPin(name: "Pin", iconString: "📍"))
        pins.append(MMPin(name: "Good", iconString: "👍"))
        pins.append(MMPin(name: "Food", iconString: "🍕"))
        pins.append(MMPin(name: "Rest", iconString: "🚻"))
        pins.append(MMPin(name: "View", iconString: "🎑"))
        pins.append(MMPin(name: "Hotel", iconString: "🏨"))
        return pins
        
    }
    func drawPolyline(){
        guard let coordinates = self.coordinates, coordinates.count > 1 else {return}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        self.coordinates?.remove(at: 0)
        mapView.add(polyline)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = self.view.bounds
        self.verticalLineLC.constant = self.mapView.center.y
        self.view.layoutSubviews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.coordinates = []
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isDrawabled {return}
        guard let touch = touches.first, touches.count == 1 else { return }
        let point = touch.location(in: self.mapView)
        let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        self.coordinates?.append(coordinate)
        self.drawPolyline()

    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
}
struct MMPin {
    let name:String
    let icon:UIImage
    init(name:String, iconString:String) {
        self.name = name
        self.icon = iconString.image()!
    }
}
extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MMAnnotation else {
            return nil
        }
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.pin.name)
        if anView == nil {
            if annotation.pin.name == "Pin" {
                let pinAnView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.pin.name)
                pinAnView.animatesDrop = true
                anView = pinAnView
                
            }else{
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.pin.name)
            }
            
            anView?.image = annotation.pin.icon
            anView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            anView?.rightCalloutAccessoryView = button
        }else{
            anView?.annotation = annotation
        }
        return anView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MMAnnotation else{return}
        
        print("\(annotation.pin.name) did selected")
    }
    

}
class MMAnnotation:NSObject, MKAnnotation {
    var pin:MMPin
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subTitle: String?
    init(pin:MMPin, coordinate:CLLocationCoordinate2D, title:String?, subTitle:String?) {
        self.pin = pin
        self.coordinate = coordinate
        self.title = title
        self.subTitle = subTitle
    }
}
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pins.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Pin Cell", for: indexPath) as! PinCollectionViewCell
        let pin = self.pins[indexPath.row]
        cell.iconImageView.image = pin.icon
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pin = self.pins[indexPath.row]
        let annotation = MMAnnotation(pin: pin, coordinate: self.mapView.convert(self.mapView.center, toCoordinateFrom: self.mapView), title: pin.name, subTitle: nil)
        mapView.addAnnotation(annotation)
    }
}

extension String {
    func image() -> UIImage? {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30)]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        
        let size = attributedString.size()
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as NSString).draw(in: rect, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

