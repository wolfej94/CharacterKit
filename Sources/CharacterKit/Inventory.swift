public class Inventory: Codable {
    
    // MARK: - Variables
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
    
    private var items: [Item]
    public var character: Character?
    
    public var armorModifier: Int {
        let armor = items(for: [.headArmor, .torsoArmor, .handsArmor, .legsArmor, .feetArmor]).filter({ $0.equipped })
        return armor.reduce(0, { $0 + $1.modifier })
    }
    
    public var damageModifier: Int {
        let armor = items(for: [.meleeWeapon, .rangedWeapon]).filter({ $0.equipped })
        return armor.reduce(0, { $0 + $1.modifier })
    }
    
    
    
    // MARK: - Initializers
    
    public init(items: [Item] = []) {
        self.items = items
    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        items = try container.decode([Item].self, forKey: .items)
    }
    
    
    
    // MARK: - Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(items, forKey: .items)
    }
    
    
    
    // MARK: - Getters
    
    public func items(for type: Item.ItemType) -> [Item] {
        return items.filter({ $0.type == type })
    }
    
    
    public func items(for types: [Item.ItemType]) -> [Item] {
        return items.filter({ types.contains($0.type) })
    }
    
    
    public func equipped(for type: Item.ItemType) -> Item? {
        return items.filter({ $0.type == type && $0.equipped }).first
    }
    
    
    public func add(item: Item) {
        items.append(item)
    }
    
    
    public func remove(item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if(item.equipped) {
            unequip(type: item.type)
        }
        
        items.remove(at: index)
    }
    
    
    public func equip(item: Item) {
        unequip(type: item.type)
        item.equipped = true
    }
    
    
    public func unequip(type: Item.ItemType) {
        equipped(for: type)?.equipped = false
    }
    
}
