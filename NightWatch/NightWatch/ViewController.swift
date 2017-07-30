//
//  ViewController.swift
//  NightWatch
//
//  Created by Chamindu Dayajeewa on 29/7/17.
//  Copyright © 2017 Chamindu Dayajeewa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, UIApplicationDelegate {
    
    //IB Outlets
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var riskLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var occurrenceLabel: UILabel!
    
    @IBOutlet var dialButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    
    //Main Constants and Variables
    
    let locationManager = CLLocationManager()
    
    var assaultStatistic = Int()
    var burglaryStatistic = Int()
    var homicideStatistic = Int()
    var offencesStatistic = Int()
    var otherOffencesStatistic = Int()
    var propertyDamageStatistic = Int()
    var roadCollisionStatistic = Int()
    var roadFatalityStatistic = Int()
    var robberyStatistic = Int()
    var sexualAssaultStatistic = Int()
    var theftStatistic = Int()
    var trafficInfringementStatistic = Int()
    var vehicleTheftStatistic = Int()
    
    var userAlerted = false
    
    //Custom Functions:
    
    func alert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func alertUser() {
        
        let userAlertContent = UNMutableNotificationContent()
        
        let alertDialOption = UNNotificationAction(identifier: "alertDialOption", title: "Dial 000", options: [])
        let alertDirectionsOption = UNNotificationAction(identifier: "alertDirectionsOption", title: "Get Directions Home", options: [])
        
        let userAlertOptions = UNNotificationCategory(identifier: "userAlertOptions", actions: [alertDialOption, alertDirectionsOption], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([userAlertOptions])
        
        userAlertContent.title = "Need Help?"
        userAlertContent.subtitle = "You might run into trouble..."
        userAlertContent.body = "Based on our stats, you are in a zone with a high crime rate at an unsafe time."
        userAlertContent.categoryIdentifier = "userAlertOptions"
        
        let testTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let userAlertRequest = UNNotificationRequest(identifier: "userAlert", content: userAlertContent, trigger: testTrigger)
        
        
        UNUserNotificationCenter.current().add(userAlertRequest) { (userAlertError) in
            
            
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Setup Custom Styling
        
        mapView.layer.cornerRadius = 20
        mapView.clipsToBounds = true
        
        riskLabel.layer.cornerRadius = 20
        riskLabel.clipsToBounds = true
        
        ratingLabel.layer.cornerRadius = 20
        ratingLabel.clipsToBounds = true
        
        occurrenceLabel.layer.cornerRadius = 20
        occurrenceLabel.clipsToBounds = true
        occurrenceLabel.numberOfLines = -1
        
        dialButton.layer.cornerRadius = 20
        dialButton.clipsToBounds = true
        
        directionsButton.layer.cornerRadius = 20
        directionsButton.clipsToBounds = true
        
        //Setup Location Manager
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        //Setup UserNotifications
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (permissionGranted, permissionError) in
            
            if permissionGranted != true {
                
                self.alert(title: "Enable Notifications", message: "You must enable notifications to benefit from NightWatch")
                
            } else {
                
                //Do nothing
                
            }
            
            if (permissionError != nil) {
                
                print("Error!")
                
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //User Location Handling
        
        let location = locations[0]
        
        let mapViewSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let mapViewRegion = MKCoordinateRegion(center: userLocation, span: mapViewSpan)
        
        mapView.setRegion(mapViewRegion, animated: true)
        
        mapView.showsUserLocation = true
        
        //Current Date Handling
        
        let date = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let hour = calendar.component(.hour, from: date)
        var quarterSection:String!
        
        if month >= 1 && month <= 3 {
            
            quarterSection = "q1"
            
        } else if month >= 3 && month <= 6 {
            
            quarterSection = "q2"
            
        } else if month >= 6 && month <= 9 {
            
            quarterSection = "q3"
            
        }  else if month >= 9 && month <= 12 {
            
            quarterSection = "q4"
            
        }
        
        //Setup Reverse Geocoding
        
        CLGeocoder().reverseGeocodeLocation(location) { (userPlacemarks, geocoderError) in
            
            if geocoderError == nil {
                
                if let suburb = userPlacemarks?[0].locality {
                    
                    //Handle JSON Crime Data
                    
                    let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "crime_data", ofType: "json")!)
                    
                    do {
                        
                        let rawCrimeData = try Data(contentsOf: filePath)
                        let crimeData = try JSONSerialization.jsonObject(with: rawCrimeData, options: .mutableContainers) as AnyObject
                        
                        if let quarter = crimeData[quarterSection] as? NSDictionary {
                            
                            if let suburbCrimeData = quarter[suburb] as? [String: AnyObject] {
                                
                                if let assaultData = suburbCrimeData["assault"] as? Int {
                                    
                                    self.assaultStatistic = assaultData
                                    
                                }
                                
                                if let burglaryData = suburbCrimeData["burglary"] as? Int {
                                    
                                    self.burglaryStatistic = burglaryData
                                    
                                }
                                
                                if let homicideData = suburbCrimeData["homicide"] as? Int {
                                    
                                    self.homicideStatistic = homicideData
                                    
                                }
                                
                                if let offencesData = suburbCrimeData["offences"] as? Int {
                                    
                                    self.offencesStatistic = offencesData
                                    
                                }
                                
                                if let otherOffencesData = suburbCrimeData["other_offences"] as? Int {
                                    
                                    self.otherOffencesStatistic = otherOffencesData
                                    
                                }
                                
                                if let propertyDamageData = suburbCrimeData["property_damage"] as? Int {
                                    
                                    self.propertyDamageStatistic = propertyDamageData
                                    
                                }
                                
                                if let roadCollisionData = suburbCrimeData["road_collision"] as? Int {
                                    
                                    self.roadCollisionStatistic = roadCollisionData
                                    
                                }
                                
                                if let roadFatalityData = suburbCrimeData["road_fatality"] as? Int {
                                    
                                    self.roadFatalityStatistic = roadFatalityData
                                    
                                }
                                
                                if let robberyData = suburbCrimeData["robbery"] as? Int {
                                    
                                    self.robberyStatistic = robberyData
                                    
                                }
                                
                                if let sexualAssaultData = suburbCrimeData["sexual_assault"] as? Int {
                                    
                                    self.sexualAssaultStatistic = sexualAssaultData
                                    
                                }
                                
                                if let theftData = suburbCrimeData["theft"] as? Int {
                                    
                                    self.theftStatistic = theftData
                                    
                                }
                                
                                if let trafficInfringementData = suburbCrimeData["traffic_infringement"] as? Int {
                                    
                                    self.trafficInfringementStatistic = trafficInfringementData
                                    
                                }
                                
                                if let vehicleTheftData = suburbCrimeData["vehicle_theft"] as? Int {
                                    
                                    self.vehicleTheftStatistic = vehicleTheftData
                                    
                                }
                                
                                //Setup Formula (decide danger/safe zones)
                                
                                let crimeListData = [self.assaultStatistic, self.burglaryStatistic, self.homicideStatistic, self.offencesStatistic, self.otherOffencesStatistic, self.propertyDamageStatistic, self.roadCollisionStatistic, self.roadFatalityStatistic, self.robberyStatistic, self.sexualAssaultStatistic, self.theftStatistic, self.trafficInfringementStatistic, self.vehicleTheftStatistic]
                                
                                let totalCrimeRecords = self.assaultStatistic + self.burglaryStatistic + self.homicideStatistic + self.offencesStatistic + self.otherOffencesStatistic + self.propertyDamageStatistic + self.roadCollisionStatistic + self.roadFatalityStatistic + self.robberyStatistic + self.sexualAssaultStatistic + self.theftStatistic + self.trafficInfringementStatistic + self.vehicleTheftStatistic
                                
                                let averageCrimes = Int(totalCrimeRecords / 13)
                                
                                self.ratingLabel.text = String(averageCrimes)
                                
                                let crimeListStrings = ["Assault", "Burglary", "Homicide", "Offences", "Other Offences", "Property Damage", "Road Collision", "Road Fatality", "Robbery", "Sexual Assault", "Theft", "Traffic Infringement", "Vehicle Theft"]
                                
                                self.occurrenceLabel.text = crimeListStrings[crimeListData.index(of: Int(crimeListData.max()!))!]
                                
                                //Setup Notifications
                                
                                if averageCrimes > 7 {
                                    
                                    self.ratingLabel.backgroundColor = UIColor.init(colorLiteralRed: 174/255, green: 37/255, blue: 50/255, alpha: 1)
                                    
                                    if hour > 7 {
                                        
                                        if self.userAlerted != true {
                                            
                                            print("user notified")
                                            self.alertUser()
                                            self.userAlerted = true
                                            
                                            self.riskLabel.text = "High Risk"
                                            self.riskLabel.backgroundColor = UIColor.init(colorLiteralRed: 214/255, green: 77/255, blue: 90/255, alpha: 1)
                                            
                                        } else {
                                            
                                            Timer.scheduledTimer(withTimeInterval: 600, repeats: false, block: { (timer) in
                                                
                                                self.userAlerted = false
                                                
                                            })
                                            
                                        }
                                        
                                    } else {
                                        
                                        self.riskLabel.text = "Currently Safe"
                                        self.riskLabel.backgroundColor = UIColor.init(colorLiteralRed: 98/255, green: 158/255, blue: 255/255, alpha: 1)
                                        
                                    }
                                    
                                } else {
                                    
                                    self.riskLabel.text = "Safe"
                                    self.riskLabel.backgroundColor = UIColor.init(colorLiteralRed: 98/255, green: 158/255, blue: 255/255, alpha: 1)
                                    
                                    self.ratingLabel.backgroundColor = UIColor.init(colorLiteralRed: 58/255, green: 118/255, blue: 215/255, alpha: 1)
                                    
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    } catch {
                        
                        print("ERROR in reading data")
                        
                    }
                    
                }
                
            } else {
                
                print("ERROR in reverse geocoding")
                
            }
            
        }
        
    }
    
    @IBAction func dialEmergency(_ sender: UIButton) {
        
        let emergencyPhoneNumber = 000
        
        let phoneNumberURL = URL(string: "tel://\(emergencyPhoneNumber)")!
        
        UIApplication.shared.open(phoneNumberURL, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func getDirectionsHome(_ sender: UIButton) {
        
        let homeLatitude:CLLocationDegrees = -35.331189
        let homeLongitude:CLLocationDegrees = 149.127167
        
        let homeDistance:CLLocationDistance = 1000
        
        let homeCoordinates = CLLocationCoordinate2DMake(homeLatitude, homeLongitude)
        
        let homeRegion = MKCoordinateRegionMakeWithDistance(homeCoordinates, homeDistance, homeDistance)
        
        let mapsLaunchOptions = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: homeRegion.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: homeRegion.span)]
        
        let homePlacemark = MKPlacemark(coordinate: homeCoordinates)
        
        let mapHomeItem = MKMapItem(placemark: homePlacemark)
        mapHomeItem.name = "Home"
        mapHomeItem.openInMaps(launchOptions: mapsLaunchOptions)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
