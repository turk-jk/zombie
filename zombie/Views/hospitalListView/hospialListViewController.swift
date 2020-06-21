//
//  hospialListViewController.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import EasyPeasy
import CoreLocation
import CoreData
import MapKit

class hospialListViewController: UIViewController {
    internal var levelOfPain: Int
    internal var fetchedResultController: FRCTableViewDataSource<WaitingItem>!
    internal var locationManger : CLLocationManager?
    
    
    /// indecates the selection was made in the tableview not in the mapview
    internal var tableSelection = false
    internal var calculateTransport = false
    internal var selectedSegmentIndex = 0
    var selectedMode: transportMode {
        get{
            return transportMode(number: selectedSegmentIndex)
        }
    }
    lazy private var fullTableConstraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
    lazy private var halfTableConstraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: view.frame.height / 1.7)
    
    var toggleMap: UIBarButtonItem!
    var refresh: UIBarButtonItem!
    
    init(levelOfPain: Int) {
        self.levelOfPain = levelOfPain
        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(mapView)
        
        fullTableConstraint.isActive = true
        
        locationManger = CLLocationManager()
        
        title = "Our suggested Hospitals"

        
        toggleMap = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-marker-29"), style: .plain, target: self, action: #selector(hospialListViewController.toggleMapPressed))
        toggleMap.tintColor = .mainColor
        refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshList))
        refresh.tintColor = .mainColor
        
        
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(ResetPressed))
        resetButton.tintColor = .mainColor
        
        self.navigationItem.rightBarButtonItems = [refresh, toggleMap]
        self.navigationItem.leftBarButtonItem = resetButton
    }
    override func viewDidAppear(_ animated: Bool) {
        
        fetchHospitalsLocally()
        fetchremoteHospitals()
    }
    
    override func viewWillLayoutSubviews() {
        
        mapView.easy.layout(
            Right()
            ,Left()
            ,Top()
            ,Bottom().to(tableView, .top)
        )
        tableView.easy.layout(
            Right()
            ,Left()
            ,Bottom()
        )
    }
    
    @objc internal func refreshList() {
        vibeIt(.light)
        self.fetchremoteHospitals()
        if calculateTransport{
            locationManger?.startUpdatingLocation()
        }
    }
    @objc internal func toggleMapPressed() {
        vibeIt(.light)
        fullTableConstraint.isActive = !fullTableConstraint.isActive
        halfTableConstraint.isActive = !halfTableConstraint.isActive
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    @objc internal func ResetPressed() {
        vibeIt(.light)
        UserDefaults.standard.removeAll()
        let illnessListView = illnessListViewController()
        self.navigationController?.viewControllers.insert(illnessListView, at: 0)
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy internal var tableView : UITableView = {
        let v = UITableView(frame: .zero, style: UITableView.Style.plain)
        v.delegate = self
        v.separatorStyle = .none
        v.estimatedRowHeight = 150
        v.rowHeight = UITableView.automaticDimension
//        v.backgroundColor = .white
        v.register(hospitalCell.self, forCellReuseIdentifier: "Cell")
        return v
    }()
    lazy var mapView : MKMapView = {
        let v = MKMapView()
        v.delegate = self
        v.showsUserLocation = true
        return v
    }()
    var mapRoute: MKRoute? {
        didSet{
            self.updateMap(with: mapRoute, oldMapRoute: oldValue)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("👍🏽 deinit \(type(of: self))")
    }
}

// MARK: - FetchedResultsController helper delegate
extension hospialListViewController: FRCTableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! hospitalCell
        row.calculateTransport = calculateTransport
        let object = fetchedResultController.object(at: indexPath)
        row.selectedMode = selectedMode
        row.object = object
        let backgroundView = UIView()
        row.selectedBackgroundView = backgroundView
        return row
    }
}
// MARK: - TableView delegate
extension hospialListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateTransport ? 96 : 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let obj = fetchedResultController.object(at: indexPath)
        tableSelection = true
        //Select marker in map and move camera to the marker
        guard let annotation = self.mapView.annotations.first (where: { (annotation) -> Bool in
            return obj.hospital.name == annotation.title
        }) else{
            print("Couldn't find annotation")
            return
        }
        print("obj \(obj.hospital.name) annotation \(annotation.title)")
        self.mapView.selectAnnotation(annotation, animated: true)
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Segemnt of transport modes
        let images = transportMode.allCases.map{$0.fillImage}
        let segment = UISegmentedControl(items: images)
        segment.isHidden = !calculateTransport
        segment.selectedSegmentIndex = selectedSegmentIndex
//        segment.backgroundColor = .white
        segment.addTarget(self, action: #selector(transportModeChanged(_:)), for: .valueChanged)
        segment.tintColor = .mainColor
        
        let label = UILabel()
        label.text = !calculateTransport ? " Calculate ETA to the hospital:" : " Calculate ETA:"
        label.adjustsFontSizeToFitWidth = true
//        label.backgroundColor = .white
        
        // Switch to turn off or on the transport mode
        let switchtransport = UISwitch()
        switchtransport.isOn = calculateTransport
        switchtransport.addTarget(self, action: #selector(calculateETAChanged(_:)), for: .valueChanged)
        switchtransport.onTintColor = .mainColor
//        switchtransport.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [label, segment, switchtransport])
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 10
        
        let view = UIView()
//        view.backgroundColor = .white
        view.addSubview(stack)
        stack.easy.layout(
            Edges()
        )
        return view
    }
    
    /// called when Transport mode is changed, update ETA
    /// - Parameter sender: SegmentedControl that was changed
    @objc func transportModeChanged(_ sender: UISegmentedControl)  {
        vibeIt(.light)
        selectedSegmentIndex = sender.selectedSegmentIndex
        self.updateETA()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}
