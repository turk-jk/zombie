//
//  HospitalStruct.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation

struct Page: Decodable {
    var size: Int
    var totalElements: Int
    var totalPages: Int
    var number: Int
    enum CodingKeys: String, CodingKey {
        case size
        case totalElements
        case totalPages
        case number
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let size = try values.decode(Int.self, forKey: .size)
        let totalElements = try values.decode(Int.self, forKey: .totalElements)
        let totalPages = try values.decode(Int.self, forKey: .totalPages)
        let number = try values.decode(Int.self, forKey: .number)
        self.init(size: size, totalElements: totalElements, totalPages: totalPages, number: number)
    }
    init(size: Int,
         totalElements: Int,
         totalPages: Int,
         number: Int) {
        self.size = 0
        self.totalElements = 0
        self.totalPages = 0
        self.number = 0
    }
}
struct _href: Decodable {
    var href: String
    enum CodingKeys: String, CodingKey {
        case href
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let href = try values.decode(String.self, forKey: .href)
        self.init(href: href)
    }
    init(href: String) {
        self.href = href
    }
}

struct Links: Decodable {
    var `self`: _href
    var next: _href?
    var prev: _href?
    enum CodingKeys: String, CodingKey {
        case `self`
        case next
        case prev
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let _self = try values.decode(_href.self, forKey: .`self`)
        let next = try? values.decode(_href.self, forKey: .next)
        let prev = try? values.decode(_href.self, forKey: .prev)
        self.init(_self: _self, next: next, prev: prev)
    }
    init(_self: _href,
         next: _href?,
         prev: _href?) {
        self.`self` = _self
        self.next = next
        self.prev = prev
    }
}

struct Location: Decodable {
    var lat: Double
    var lng: Double
    enum CodingKeys: String, CodingKey {
        case lat
        case lng
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try values.decode(Double.self, forKey: .lat)
        let lng = try values.decode(Double.self, forKey: .lng)
        self.init(lat: lat, lng: lng)
        
    }
    init(lat: Double,
         lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}
struct waitingItem: Decodable {
    var patientCount: Int
    var levelOfPain: Int
    var averageProcessTime: Int
    enum CodingKeys: String, CodingKey {
        case patientCount
        case levelOfPain
        case averageProcessTime
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let patientCount = try values.decode(Int.self, forKey: .patientCount)
        let levelOfPain = try values.decode(Int.self, forKey: .levelOfPain)
        let averageProcessTime = try values.decode(Int.self, forKey: .averageProcessTime)
        
        self.init(patientCount: patientCount, levelOfPain: levelOfPain, averageProcessTime: averageProcessTime)
    }
    init(patientCount: Int,
         levelOfPain: Int,
         averageProcessTime: Int) {
        self.patientCount = patientCount
        self.levelOfPain = levelOfPain
        self.averageProcessTime = averageProcessTime
    }
}

struct hospital: Decodable {
    var id: Int
    var name: String
    var waitingList: [waitingItem]
    var location: Location
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case waitingList
        case location
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(Int.self, forKey: .id)
        let name = try values.decode(String.self, forKey: .name)
        let waitingList = try values.decode([waitingItem].self, forKey: .waitingList)
        let location = try values.decode(Location.self, forKey: .location)
        self.init(id: id, name: name, waitingList: waitingList, location: location)
    }
    init(id: Int,
         name: String,
         waitingList: [waitingItem],
         location: Location) {
        self.id = id
        self.name = name
        self.waitingList = waitingList
        self.location = location
    }
}

struct Embedded: Decodable {
    var hospitals: [hospital]
    enum CodingKeys: String, CodingKey {
        case hospitals
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let hospitals = try values.decode([hospital].self, forKey: .hospitals)
        self.init(hospitals: hospitals)
    }
    init(hospitals: [hospital]) {
        self.hospitals = hospitals
    }
}

struct HospitalStruct: Decodable {
    var page: Page
    var _links: Links
    var _embedded: Embedded
    enum CodingKeys: String, CodingKey {
        case page
        case _links
        case _embedded
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let page = try values.decode(Page.self, forKey: .page)
        let _links = try values.decode(Links.self, forKey: ._links)
        let _embedded = try values.decode(Embedded.self, forKey: ._embedded)
        self.init(page: page, _links: _links, _embedded: _embedded)
    }
    init(page: Page,
         _links: Links,
         _embedded: Embedded) {
        self.page = page
        self._links = _links
        self._embedded = _embedded
    }
    
    var hospitals: [hospital]{
        return _embedded.hospitals
    }
}
