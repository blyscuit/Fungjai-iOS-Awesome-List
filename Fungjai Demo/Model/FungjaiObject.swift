//
//  FungjaiObject.swift
//  Fungjai Demo
//
//  Created by Bliss Watchaye on 2018-03-21.
//  Copyright © 2018 fungjai. All rights reserved.
//

import Foundation

enum FungjaiObjectType {
	case track
	case video
	case ads
}

class FungjaiObject {
	var name: String = ""
	var id: Int = 0
	var type: FungjaiObjectType = FungjaiObjectType.track
	var cover: String = ""
	
	init(dictionary: [String: Any]) {
		self.name = dictionary["name"] as? String ?? ""
		self.id = dictionary["id"] as? Int ?? 0
		self.cover = dictionary["cover"] as? String ?? ""
		let typeDescription = dictionary["type"] as? String ?? ""
		switch typeDescription {
			case "track":
				self.type = FungjaiObjectType.track
			case "ads":
				self.type = FungjaiObjectType.ads
			case "video":
				self.type = FungjaiObjectType.video
			default:
				self.type = FungjaiObjectType.video
		}
	}
}

class FungjaiVideo: FungjaiObject {
}
class FungjaiTrack: FungjaiObject {
}
class FungjaiAds: FungjaiObject {
}
