//
//  PageViewController.swift
//  NightWatch
//
//  Created by Chamindu Dayajeewa on 29/7/17.
//  Copyright © 2017 Chamindu Dayajeewa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class PageViewController: UIViewController {

    @IBOutlet var pageView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        pageView.contentSize.width = pageView.frame.width * 2
        
        let homeView = storyboard.instantiateViewController(withIdentifier: "homeView").view!
        let statisticsView = storyboard.instantiateViewController(withIdentifier: "statisticsView").view!
        
        homeView.frame = CGRect(x: pageView.frame.width * 0, y: 0, width: pageView.frame.width, height: pageView.frame.height)
        statisticsView.frame = CGRect(x: pageView.frame.width * 1, y: 0, width: pageView.frame.width, height: pageView.frame.height)
        
        pageView.addSubview(homeView)
        pageView.addSubview(statisticsView)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
