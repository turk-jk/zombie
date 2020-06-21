//
//  illnessListViewController.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit

class illnessListViewController: UIViewController {
    
    var selectedIndex : IndexPath?{
        didSet{
            if let selectedIndex = selectedIndex{
                tableView.reloadRows(at: [selectedIndex], with: .automatic)
                if selectedIndex.row == illnesses.count - 1 {
                    tableView.scrollToRow(at: selectedIndex, at: .bottom, animated: true)
                }
            }
            
            if let oldSelectedIndex = oldValue{
                tableView.reloadRows(at: [oldSelectedIndex], with: .automatic)
            }
        }
    }
    /// decelerate scrolling
    private var decelerate = false
    internal var illnesses = [illnesseItem](){
        didSet{
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select an illness"
        view = tableView
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchIllness()
    }
    

    lazy var tableView : UITableView = {
        let v = UITableView(frame: .zero, style: UITableView.Style.plain)
        v.delegate = self
        v.dataSource = self
        v.separatorStyle = .none
        v.estimatedRowHeight = 150
        v.rowHeight = UITableView.automaticDimension
//        v.backgroundColor = .white
        v.register(illnessCell.self, forCellReuseIdentifier: "Cell")
        return v
    }()
    
    func fetchIllness(page: Int = 0) {
        API.illnesses(page: page).fetch { (_struct, error) in
            if let error = error{
                print("error in fetchIllness is \(error.localizedDescription)")
                return
            }
            guard let _struct = _struct as? IllnessesStruct else{
                return
            }
            
            if let next = _struct._links.next?.href, !next.isEmpty{

                print("downloading more Illness")
                self.fetchIllness(page: page + 1)
            }else{
                print("no more Illness to download ")
                
            }
            self.illnesses.append(contentsOf:_struct.illnesses)
        }
    }
    
    deinit {
        print("👍🏽 deinit \(type(of: self))")
    }
}
extension illnessListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return illnesses.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! illnessCell
        row.showPainLevel = self.selectedIndex == indexPath
//        row.backgroundColor = backgroundColor
        row.tag = indexPath.row
        row.delegate = self
        let illness = self.illnesses[indexPath.row]
        row.illnessName = illness.name
        return row
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         
        return self.selectedIndex == indexPath ? 141 : 66
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndex == indexPath{
            tableView.deselectRow(at: indexPath, animated: true)
            self.selectedIndex = nil
        }else{
            self.selectedIndex = indexPath
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if decelerate{
            decelerate = false
            if let selectedIndex = selectedIndex{
                tableView.deselectRow(at: selectedIndex, animated: true)
            }
            self.selectedIndex = nil
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.decelerate = decelerate
        
    }
}
extension illnessListViewController: illnessDelgate{
     func reportIllness(at index: Int, illnessName: String, levelOfPain: Int) {
           UserDefaults.standard.set(illnessName, forKey: st.illnessName.s)
           UserDefaults.standard.set(levelOfPain, forKey: st.levelOfPain.s)
           UserDefaults.standard.set(true, forKey: st.hasLevelOfPain.s)
           let hospialListView = hospialListViewController(levelOfPain: levelOfPain)
           self.navigationController?.pushViewController(hospialListView, animated: true)
           self.navigationController?.viewControllers.remove(at: 0)
       }
}

