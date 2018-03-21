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
import Siesta

class ViewController: UIViewController {
	@IBOutlet weak var mainTable: UITableView!
	var tableDataArray: [FungjaiObject]! = []
	let MyAPI = Service(baseURL: "https://www.anop72.info/api")

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.mainTable.dataSource = self
		self.mainTable.delegate = self
		self.mainTable.es.addPullToRefresh {
			[unowned self] in
//			self.loadData()
			if self.MyAPI.resource("/seed.json").loadIfNeeded() == nil {
				self.mainTable.es.stopPullToRefresh()
			}
		}
		
//		loadData()
		
		MyAPI.resource("/seed.json").addObserver(owner: self) {
			[weak self] resource, event in
			guard let _self = self else {
				DispatchQueue.main.async {
					self?.mainTable.es.stopPullToRefresh()
					let alert = UIAlertController(title: "Error", message: "Something went wrong, try again later.", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
					self?.present(alert, animated: true, completion: nil)
				}
				return
			}
			if let error = resource.latestError {
				let alert = UIAlertController(title: "Error", message: error.userMessage, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
				_self.present(alert, animated: true, completion: nil)
				_self.mainTable.es.stopPullToRefresh()
			} else {
				_self.tableDataArray.removeAll()
				for obj in resource.jsonArray as! [Dictionary<String, AnyObject>] {
					let typeDescription = obj["type"] as? String ?? ""
					switch typeDescription {
					case "track":
						_self.tableDataArray.append(FungjaiTrack(dictionary: obj))
					case "ads":
						_self.tableDataArray.append(FungjaiAds(dictionary: obj))
					case "video":
						_self.tableDataArray.append(FungjaiVideo(dictionary: obj))
					default:
						_self.tableDataArray.append(FungjaiVideo(dictionary: obj))
					}
				}
				DispatchQueue.main.async {
					_self.mainTable.reloadData()
					_self.mainTable.es.stopPullToRefresh()
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible = resource.isLoading
			}
		}
		MyAPI.resource("/seed.json").loadIfNeeded()

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// URLSession method is not used
	// To switch to URLSession method, uncomment all loadData() & comment all MyAPI.resource("/seed.json").loadIfNeeded()
	func loadData() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		let url : String = "https://www.anop72.info/api/seed.json"
		
		URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			do {
				let json = try JSONSerialization.jsonObject(with: data!) as! [Dictionary<String, AnyObject>]
				self.tableDataArray.removeAll()
				for obj in json {
					let typeDescription = obj["type"] as? String ?? ""
					switch typeDescription {
					case "track":
						self.tableDataArray.append(FungjaiTrack(dictionary: obj))
					case "ads":
						self.tableDataArray.append(FungjaiAds(dictionary: obj))
					case "video":
						self.tableDataArray.append(FungjaiVideo(dictionary: obj))
					default:
						self.tableDataArray.append(FungjaiVideo(dictionary: obj))
					}
				}
				DispatchQueue.main.async {
					self.mainTable.reloadData()
					self.mainTable.es.stopPullToRefresh()
				}
			} catch {
				DispatchQueue.main.async {
					self.mainTable.es.stopPullToRefresh()
					let alert = UIAlertController(title: "Error", message: "Something went wrong, try again later.", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
					self.present(alert, animated: true, completion: nil)
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
