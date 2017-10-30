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
import Fuzi
import FileBrowser

class ViewController: UIViewController{
    var pins:[MMPin] = []
    var savedAnnotation:[MMAnnotation] = []
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var pinCollectionView: UICollectionView!
    @IBOutlet weak var verticalLineLC: NSLayoutConstraint!
    var locationManager:CLLocationManager?
    var fileBrowser = FileBrowser()
    @IBAction func loadFileAction(_ sender: Any) {
        present(fileBrowser, animated: true, completion: nil)
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            self.loadExternalGPXFile(url: file.filePath)
        }

    }
    var pinnedPins:[MMAnnotation] {
        return self.mapView.annotations.flatMap({$0 as? MMAnnotation})
    }
    @IBAction func saveAllPinAction(_ sender: Any) {
        var gpx = GPX()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        let name = dateFormatter.string(from: Date())
        gpx.name = name
        gpx.desc = ""
        var waypoints:[Waypoint] = []
        for annotation in self.pinnedPins {
            let waypoint = Waypoint(coordinate: annotation.coordinate, date: annotation.pinnedDate, name: annotation.title ?? "", desc: nil, type: WaypointType(name: annotation.pin.name))
            waypoints.append(waypoint)
        }
        gpx.waypoints = waypoints
        print(gpx.getXMLString())
        if let url = self.exportToFileURL(gpx: gpx) {
            let urlObjectsToShare = [url]
            let activityVc = UIActivityViewController(activityItems: urlObjectsToShare, applicationActivities: nil)
            activityVc.popoverPresentationController?.sourceView = sender as? UIButton
            self.present(activityVc, animated: true, completion: nil)
        }
        

        
        
    }
    func exportToFileURL(gpx:GPX) -> URL? {
        guard let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
        }
        
        let saveFileURL = path.appendingPathComponent("gpx.gpx")
        do {
        try gpx.getXMLString().write(to: saveFileURL, atomically: true, encoding:String.Encoding.utf8)
            return saveFileURL
        }catch {
            NSLog("save file error")
            return nil
        }
    }

    
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
        if let coordinates = self.loadGPX() {
            let polyline = MMPolyline(coordinates: coordinates, count: coordinates.count)
            polyline.lineWidth = 2
            polyline.color = .blue
            mapView.add(polyline)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.newGPXFile, object: nil, queue: .main) { (noti) in
            guard let url = noti.object as? URL else{return}
            self.loadExternalGPXFile(url: url)
        }
    }
    func loadExternalGPXFile(url:URL){
        guard let coordinates = self.loadGPX(fileURL: url) else{return}
        let polyline = MMPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.lineWidth = 2
        polyline.color = .red
        self.mapView.add(polyline)

    }
    func loadGPX(fileURL:URL? = nil) -> [CLLocationCoordinate2D]?{
        var fileURL = fileURL
        if fileURL == nil {
            fileURL = Bundle.main.url(forResource: "test", withExtension: "gpx")
        }
        guard let url = fileURL else{return nil}
        let xml = try! String(contentsOf: url, encoding:.utf8)
        var coordinates:[CLLocationCoordinate2D] = []
        do {
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let document = try XMLDocument(string: xml, encoding: .utf8)
            
            if let root = document.root {
                
                //                print(root.tag)
                
                // define a prefix for a namespace
                //                document.definePrefix("xml", defaultNamespace: "http://www.topografix.com/GPX/1/1")
                
                // get first child element with given tag in namespace(optional)
                guard let tracks = root.firstChild(tag: "trk")?.firstChild(tag: "trkseg")?.children(tag: "trkpt") else{return nil}
                let numberFormatter = NumberFormatter()
                for track in tracks {
                    var logMessage:String = ""
                    if let lat = track.attr("lat"), let lon = track.attr("lon")
                        , let latNum = numberFormatter.number(from: lat)
                        , let lonNum = numberFormatter.number(from: lon)
                    {
                        let coordinate = CLLocationCoordinate2D(latitude: latNum.doubleValue, longitude: lonNum.doubleValue)
                        coordinates.append(coordinate)
                        logMessage += "lat:\(lat), lon:\(lon)"
                    }
                    if let time = track.firstChild(tag: "time") {
                        logMessage += "(\(time))"
                    }
                    print(logMessage)
                }
            }
            // you can also use CSS selector against XMLDocument when you feels it makes sense
        } catch let error as XMLError {
            switch error {
            case .noError: print("wth this should not appear")
            case .parserFailure, .invalidData: print(error)
            case .libXMLError(let code, let message):
                print("libxml error code: \(code), message: \(message)")
            }
        }catch {
            print(error)
        }
        return coordinates
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
        if let coordinates = self.coordinates, coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: [coordinates[0],coordinates[1]], count: 2)
            self.mapView.add(polyline)
            self.coordinates?.remove(at: 0)
        }


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
            if let overlay = overlay as? MMPolyline {
                renderer.strokeColor = overlay.color
                renderer.lineWidth = overlay.lineWidth
            }else{
                renderer.strokeColor = UIColor.orange
                renderer.lineWidth = 3
            }
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
class MMPolyline:MKPolyline {
    var color:UIColor = .orange
    var lineWidth:CGFloat = 3
}
class MMAnnotation:NSObject, MKAnnotation {
    var pin:MMPin
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subTitle: String?
    var pinnedDate:Date
    init(pin:MMPin, coordinate:CLLocationCoordinate2D, title:String?, subTitle:String?) {
        self.pin = pin
        self.coordinate = coordinate
        self.title = title
        self.subTitle = subTitle
        self.pinnedDate = Date()
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
        let count = pinnedPins.filter { (annotation) -> Bool in
            return annotation.pin.name == pin.name
        }.count
        let annotation = MMAnnotation(pin: pin, coordinate: self.mapView.convert(self.mapView.center, toCoordinateFrom: self.mapView), title: pin.name + String(count + 1), subTitle: nil)
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

