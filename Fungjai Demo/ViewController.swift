//
//  ViewController.swift
//  Fungjai Demo
//
//  Created by Bliss Watchaye on 2018-03-21.
//  Copyright © 2018 fungjai. All rights reserved.
//

import UIKit
import ESPullToRefresh
import Kingfisher

class ViewController: UIViewController {
	@IBOutlet weak var mainTable: UITableView!
	var tableDataArray: [FungjaiObject]! = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.mainTable.dataSource = self
		self.mainTable.delegate = self
		self.mainTable.es.addPullToRefresh {
			[unowned self] in
			self.loadData()
		}
		
		loadData()
		
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func loadData() {
		var url : String = "https://www.anop72.info/api/seed.json"
		
		URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
			// Handle result
//			if let response = response {
//				print(response)
//			} else {
//
//			}
			do {
				let json = try JSONSerialization.jsonObject(with: data!) as! [Dictionary<String, AnyObject>]
				self.tableDataArray = []
				for obj in json {
					self.tableDataArray.append(FungjaiObject(dictionary: obj))
				}
				print(self.tableDataArray)
				DispatchQueue.main.async {
					self.mainTable.reloadData()
					self.mainTable.es.stopPullToRefresh()
				}
			} catch {
				DispatchQueue.main.async {
					let alert = UIAlertController(title: "Error", message: "Something went wrong, try again later.", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
					self.present(alert, animated: true, completion: nil)
					self.mainTable.es.stopPullToRefresh()
				}
			}
			}.resume()
	}
	
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let dataObject = self.tableDataArray[indexPath.row]
		let url = URL(string:dataObject.cover)
		if dataObject.type == FungjaiObjectType.track {
			let cell: TrackTableViewCell = tableView.dequeueReusableCell(withIdentifier: "track") as! TrackTableViewCell
			cell.titleLabel?.text = dataObject.name
			cell.albumCover.kf.setImage(with: url)
			return cell
		}
		else if dataObject.type == FungjaiObjectType.ads {
			let cell: AdsTableViewCell =  tableView.dequeueReusableCell(withIdentifier: "ads") as! AdsTableViewCell
			cell.adsImage.kf.setImage(with: url)
			return cell
		}
		else {
			let cell: VideoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "video") as! VideoTableViewCell
			cell.videoImage.kf.setImage(with: url)
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tableDataArray.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let dataObject = self.tableDataArray[indexPath.row]
		switch dataObject.type {
			case .track:
				return 100
			case .ads:
				return 76
			case .video:
				return 165
			default:
				return 165
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
