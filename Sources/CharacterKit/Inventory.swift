public class Inventory {
    
    // MARK: - Variables
    
    private var items: [Item]
    var character: Character?
    
    var armorModifier: Int {
        let armor = items(for: [.headArmor, .torsoArmor, .handsArmor, .legsArmor, .feetArmor]).filter({ $0.equipped })
        return armor.reduce(0, { $0 + $1.modifier })
    }
    
    var damageModifier: Int {
        let armor = items(for: [.meleeWeapon, .rangedWeapon]).filter({ $0.equipped })
        return armor.reduce(0, { $0 + $1.modifier })
    }
    
    
    
    // MARK: - Initializers
    
    init(items: [Item] = []) {
        self.items = items
    }
    
    
    // MARK: - Getters
    
    func items(for type: Item.ItemType) -> [Item] {
        return items.filter({ $0.type == type })
    }
    
    
    func items(for types: [Item.ItemType]) -> [Item] {
        return items.filter({ types.contains($0.type) })
    }
    
    
    func equipped(for type: Item.ItemType) -> Item? {
        return items.filter({ $0.type == type && $0.equipped }).first
    }
    
    
    func add(item: Item) {
        items.append(item)
    }
    
    
    func remove(item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if(item.equipped) {
            unequip(type: item.type)
        }
        
        items.remove(at: index)
    }
    
    
    func equip(item: Item) {
        unequip(type: item.type)
        item.equipped = true
    }
    
    
    func unequip(type: Item.ItemType) {
        equipped(for: type)?.equipped = false
    }
    
}
