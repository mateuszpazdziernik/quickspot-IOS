import Foundation
import UIKit

import CoreLocation

import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class SpotTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var sortButton: UIButton!
    public var sortingRule: Int = 0
    
    func sortMenu() -> UIMenu {
        let menuItems = UIMenu(title: "Sort by:", options: .displayInline, children: [
            UIAction(title: "a-z", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 0)}),
            UIAction(title: "z-a", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 1)}),
            UIAction(title: "distUP", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 2)}),
            UIAction(title: "distDOWN", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 3)})
        ])
        return menuItems
    }
    
    func nextSortingRule() {
        if (sortingRule<3){sortingRule+=1} else {sortingRule = 0}
        print(sortingRule)
        loadData()
    }
    func setSortingRule(x: Int) {
        sortingRule = x
        print(sortingRule)
        loadData()
    }
    
    @IBOutlet var spotTableView: UITableView!
    let locationManager = CLLocationManager()
    var documents: [DocumentSnapshot] = []
    var currentLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    var db: Firestore!
    
    var dataArray: [Spot] = []
    
    func loadData() {
        db.collection("spots").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents : \(err)")
            }
            else {
                var price:String
                var pinCoord:CLLocation
                for document in QuerySnapshot!.documents {
                    let formatter = NumberFormatter()
                    formatter.minimumFractionDigits = 2
                    formatter.maximumFractionDigits = 2
                    
                    let documentID = document.documentID
                    price = document.data()["price"] as! String
                    let priceArray:Array = price.components(separatedBy: ";")
                    let streetName = document.data()["street"] as! String
                    let hours = document.data()["hours"] as! String
                    
                    let pinLatitude = (document.data()["location"] as! GeoPoint).latitude
                    let pinLongitude = (document.data()["location"] as! GeoPoint).longitude
                    pinCoord = CLLocation(latitude: pinLatitude, longitude: pinLongitude)
                    
                    let distance = self.currentLocation.distance(from:pinCoord)
                    //self.dataArray.append(Spot(firestoreID: documentID, location: pinCoord, price: priceArray, street: streetName, distance: "\(formatter.string(for: distance/1000)!)"))
                    self.dataArray.append(Spot(firestoreID: documentID, location: pinCoord, hours: hours, price: priceArray, street: streetName, distance: Int(distance)))
                }
                
                let backgroundView = UIImageView(image: UIImage(named: "background"))
                self.tableView.backgroundView = backgroundView
                
                switch self.sortingRule {
                case 0:
                    self.dataArray = self.dataArray.sorted(by: {$0.street < $1.street})
                    self.tableView.reloadData()
                case 1:
                    self.dataArray = self.dataArray.sorted(by: {$1.street < $0.street})
                    self.tableView.reloadData()
                case 2:
                    self.dataArray = self.dataArray.sorted(by: {$0.distance < $1.distance})
                    self.tableView.reloadData()
                case 3:
                    self.dataArray = self.dataArray.sorted(by: {$1.distance < $0.distance})
                    self.tableView.reloadData()
                default:
                    print("sortingRuleERROR")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        sortButton.addAction(UIAction(title: "", handler: {(_) in self.nextSortingRule()}), for: .touchUpInside)
        sortButton.menu = sortMenu()
        
        db = Firestore.firestore()
        loadData()
        /*
        func sortMenu() -> UIMenu {
            let menuItems = UIMenu(title: "Sort by:", options: .displayInline, children: [
                UIAction(title: "a-z", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 0)}),
                UIAction(title: "z-a", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 1)}),
                UIAction(title: "distUP", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 2)}),
                UIAction(title: "distDOWN", image: UIImage(systemName: ""), handler: {(_) in self.setSortingRule(x: 3)})
            ])
            return menuItems
        }
        
        func nextSortingRule() {
            if (sortingRule<3){sortingRule+=1} else {sortingRule = 0}
            print(sortingRule)
            loadData()
        }
        func setSortingRule(x: Int) {
            sortingRule = x
            print(sortingRule)
            loadData()
        }*/
        /*
        func loadData() {
            db.collection("spots").getDocuments() { (QuerySnapshot, err) in
                if let err = err {
                    print("Error getting documents : \(err)")
                }
                else {
                    var price:String
                    var pinCoord:CLLocation
                    for document in QuerySnapshot!.documents {
                        let formatter = NumberFormatter()
                        formatter.minimumFractionDigits = 2
                        formatter.maximumFractionDigits = 2
                        
                        let documentID = document.documentID
                        price = document.data()["price"] as! String
                        let priceArray:Array = price.components(separatedBy: ";")
                        let streetName = document.data()["street"] as! String
                        let hours = document.data()["hours"] as! String
                        
                        let pinLatitude = (document.data()["location"] as! GeoPoint).latitude
                        let pinLongitude = (document.data()["location"] as! GeoPoint).longitude
                        pinCoord = CLLocation(latitude: pinLatitude, longitude: pinLongitude)
                        
                        let distance = self.currentLocation.distance(from:pinCoord)
                        //self.dataArray.append(Spot(firestoreID: documentID, location: pinCoord, price: priceArray, street: streetName, distance: "\(formatter.string(for: distance/1000)!)"))
                        self.dataArray.append(Spot(firestoreID: documentID, location: pinCoord, hours: hours, price: priceArray, street: streetName, distance: Int(distance)))
                    }
                    
                    let backgroundView = UIImageView(image: UIImage(named: "background"))
                    self.tableView.backgroundView = backgroundView
                    
                    switch self.sortingRule {
                    case 0:
                        self.dataArray = self.dataArray.sorted(by: {$1.street < $0.street})
                        self.tableView.reloadData()
                    case 1:
                        self.dataArray = self.dataArray.sorted(by: {$0.street < $1.street})
                        self.tableView.reloadData()
                    case 2:
                        self.dataArray = self.dataArray.sorted(by: {$0.distance < $1.distance})
                        self.tableView.reloadData()
                    case 3:
                        self.dataArray = self.dataArray.sorted(by: {$1.distance < $0.distance})
                        self.tableView.reloadData()
                    default:
                        print("sortingRuleERROR")
                    }
                }
            }
        }*/
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocation = manager.location else { return }
        currentLocation = locValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for: indexPath)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let street = dataArray[indexPath.row].street
        let priceArray = dataArray[indexPath.row].price
        let distance = Double(dataArray[indexPath.row].distance)
        let hours = dataArray[indexPath.row].hours
        
        var content = cell.defaultContentConfiguration()
        content.secondaryText = """
        ul. \(street)
        
        Godziny otwarcia: \(hours)
        
        Pierwsza godzina postoju: \(priceArray[0])
        Druga godzina postoju:      \(priceArray[1])
        Trzecia godzina postoju:    \(priceArray[2])
        Kolejne godziny postoju:    \(priceArray[3])/h
        
        """
        content.text = "\nDystans: \(formatter.string(for: distance/1000)!) km"
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .white
        cell.backgroundColor = UIColor.clear
        cell.contentConfiguration = content
        print(cell)
        
        return cell
    }
}
