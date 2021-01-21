class Item {
    
    // MARK: - Variables
    
    let id: Int
    let name: String
    let value: Int
    let type: ItemType
    let modifier: Int
    var equipped: Bool
    
    var equippable: Bool { isArmor || isWeapon }
    var isConsumable: Bool { type == .consumable }
    var isArmor: Bool { type == .headArmor || type == .torsoArmor || type == .handsArmor || type == .legsArmor || type == .feetArmor }
    var isWeapon: Bool { type == .meleeWeapon || type == .rangedWeapon }
    
    
    
    // MARK: - Initializers
    
    init(id: Int, name: String, value: Int, type: ItemType, modifier: Int, inventory: Inventory? = nil, equipped: Bool? = nil) {
        self.id = id
        self.name = name
        self.value = value
        self.type = type
        self.modifier = modifier
        self.equipped = equipped ?? false
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
    
}
