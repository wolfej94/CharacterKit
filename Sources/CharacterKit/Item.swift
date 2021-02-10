public class Item: Codable {
    
    // MARK: - Variables
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case value = "value"
        case type = "type"
        case modifier = "modifier"
        case equipped = "equipped"
    }
    
    public let id: Int
    public let name: String
    public let value: Int
    public let type: ItemType
    public let modifier: Int
    public var equipped: Bool
    
    public var equippable: Bool { isArmor || isWeapon }
    public var isConsumable: Bool { type == .consumable }
    public var isArmor: Bool { type == .headArmor || type == .torsoArmor || type == .handsArmor || type == .legsArmor || type == .feetArmor }
    public var isWeapon: Bool { type == .meleeWeapon || type == .rangedWeapon }
    
    
    
    // MARK: - Initializers
    
    public init(id: Int, name: String, value: Int, type: ItemType, modifier: Int, inventory: Inventory? = nil, equipped: Bool? = nil) {
        self.id = id
        self.name = name
        self.value = value
        self.type = type
        self.modifier = modifier
        self.equipped = equipped ?? false
    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(Int.self, forKey: .value)
        modifier = try container.decode(Int.self, forKey: .modifier)
        equipped = try container.decode(Int.self, forKey: .equipped) == 1
        
        guard let typeRaw = try? container.decode(Int.self, forKey: .type), typeRaw <= 8, typeRaw >= 0  else { throw ItemDecodeError.typeParse }
        type = ItemType(rawValue: typeRaw) ?? .meleeWeapon
    }
    
    
    
    // MARK: - Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(modifier, forKey: .modifier)
        try container.encodeIfPresent(equipped ? 1 : 0, forKey: .equipped)
    }
    
}



extension Item {
    
    public enum ItemType: Int {
        case meleeWeapon = 0
        case rangedWeapon
        case headArmor
        case torsoArmor
        case handsArmor
        case legsArmor
        case feetArmor
        case consumable
        case misc
    }
    
    
    
    public enum ItemDecodeError: Error {
        
        case typeParse
        
        public var errorDescription: String {
            switch self {
                case .typeParse:
                    return "Could not parse itme type"
            }
        }
    }
    
}
