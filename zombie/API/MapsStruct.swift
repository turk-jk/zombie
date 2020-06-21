//
//  MapsStruct.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation

struct Values: Decodable {
    var text: String
    var value: Int
    enum CodingKeys: String, CodingKey {
        case text
        case value
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let text = try values.decode(String.self, forKey: .text)
        let value = try values.decode(Int.self, forKey: .value)
        self.init(text: text, value: value)
    }
    init(text: String,
         value: Int) {
        self.text = text
        self.value = value
    }
    
}


struct element: Decodable {
    var status: String
    var distance: Values
    var duration: Values
    enum CodingKeys: String, CodingKey {
        case status
        case distance
        case duration
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let status = try values.decode(String.self, forKey: .status)
        let distance = try values.decode(Values.self, forKey: .distance)
        let duration = try values.decode(Values.self, forKey: .duration)
        self.init(status: status, distance: distance, duration: duration)
        
    }
    init(status: String,
         distance: Values,
         duration: Values) {
        self.status = status
        self.distance = distance
        self.duration = duration
    }
}

struct row: Decodable {
    var elements: [element]
    enum CodingKeys: String, CodingKey {
        case elements
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let elements = try values.decode([element].self, forKey: .elements)
        self.init(elements: elements)
    }
    init(elements : [element]) {
        self.elements = elements
    }
}

struct MapsStruct: Decodable {
    
    var origin_addresses :[String]
    var destination_addresses :[String]
    var status :String
    var rows : [row]
    enum CodingKeys: String, CodingKey {
        
        case rows
        case origin_addresses
        case destination_addresses
        case status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let origin_addresses = try values.decode([String].self, forKey: .origin_addresses)
        let destination_addresses = try values.decode([String].self, forKey: .destination_addresses)
        let rows = try values.decode([row].self, forKey: .rows)
        let status = try values.decode(String.self, forKey: .status)
        self.init(origin_addresses: origin_addresses,
                  destination_addresses: destination_addresses,
                  status: status,
                  rows: rows)
    }
    init(origin_addresses :[String],
         destination_addresses :[String],
         status :String,
         rows : [row]) {
        self.origin_addresses = origin_addresses
        self.destination_addresses = destination_addresses
        self.rows = rows
        self.status = status
    }
    var distance: [String]?{
        return rows.first?.elements.map{$0.distance.text}
    }
    
    var durationString:[String]?{
        return rows.first?.elements.map{$0.duration.text}
    }
    
    var durations:[Int]?{
        return rows.first?.elements.map{$0.duration.value}
    }
}
