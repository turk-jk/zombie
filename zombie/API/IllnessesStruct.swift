//
//  IllnessesStruct.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation


struct illness: Decodable {
    var name: String
    var id: Int
    enum CodingKeys: String, CodingKey {
        
        case name
        case id
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let name = try values.decode(String.self, forKey: .name)
        let id = try values.decode(Int.self, forKey: .id)
        self.init(name: name, id: id)
    }
    init(name: String,
         id: Int) {
        self.name = name
        self.id = id
    }
    
}

struct illnesseItem: Decodable {
    var _illness: illness
    enum CodingKeys: String, CodingKey {
        case _illness = "illness"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let _illness = try values.decode(illness.self, forKey: ._illness)
        self.init(_illness: _illness)
        
    }
    init(_illness: illness) {
        self._illness = _illness
    }
    var name: String{
        return _illness.name
    }
}

struct IllnessesEmbedded: Decodable {
    var illnesses: [illnesseItem]
    enum CodingKeys: String, CodingKey {
        case illnesses
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let illnesses = try values.decode([illnesseItem].self, forKey: .illnesses)
        self.init(illnesses: illnesses)
    }
    init(illnesses : [illnesseItem]) {
        self.illnesses = illnesses
    }
}


struct IllnessesStruct: Decodable {
    var page: Page
    var _links: Links
    var _embedded: IllnessesEmbedded
    enum CodingKeys: String, CodingKey {
        case page
        case _links
        case _embedded
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let page = try values.decode(Page.self, forKey: .page)
        let _links = try values.decode(Links.self, forKey: ._links)
        let _embedded = try values.decode(IllnessesEmbedded.self, forKey: ._embedded)
        self.init(page: page, _links: _links, _embedded: _embedded)
    }
    init(page: Page,
         _links: Links,
         _embedded: IllnessesEmbedded) {
        self.page = page
        self._links = _links
        self._embedded = _embedded
    }
    
    var illnesses: [illnesseItem]{
        return _embedded.illnesses
    }
}
