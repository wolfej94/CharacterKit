public class Character {
    
    // MARK: - Variables
    
    private(set) var level: Int
    private(set) var experience: Int
    private(set) var strength: Int
    private(set) var perception: Int
    private(set) var endurance: Int
    private(set) var charisma: Int
    private(set) var intelligence: Int
    private(set) var agility: Int
    private(set) var luck: Int
    private(set) var health: Int
    private(set) var name: String
    private(set) var gold: Int
    let inventory: Inventory
    
    var experienceRequired: Int {
        if(level == 70) { return 0 }
        let nextLevel = level + 1
        return nextLevel * 100
    }
    
    var needsLevelUp: Bool {
        return level == 70 ? false : experience >= experienceRequired
    }
    
    var isDead: Bool {
        return health <= 0
    }
    
    private var luckCheck: Bool {
        let threshold = 11 - luck
        return Int.random(in: 1..<12) >= threshold
    }
    
    private var dodgeCheck: Bool {
        let threshold = 11 - agility
        return Int.random(in: 1..<12) <= threshold
    }
    
    private var hitCheck: Bool {
        let threshold = 11 - perception
        return Int.random(in: 1..<12) >= threshold
    }
    
    
    
    // MARK: - Initializers
    
    init(level: Int = 1, experience: Int = 0, strength: Int = 1, perception: Int = 1, endurance: Int = 1, charisma: Int = 1, intelligence: Int = 1, agility: Int = 1, luck: Int = 1, health: Int = 100, name: String, gold: Int = 100, inventory: Inventory? = nil) {
        self.level = level
        self.experience = experience
        self.strength = strength
        self.perception = perception
        self.endurance = endurance
        self.charisma = charisma
        self.intelligence = intelligence
        self.agility = agility
        self.luck = luck
        self.health = health
        self.name = name
        self.gold = gold
        self.inventory = inventory ?? Inventory()
        self.inventory.character = self
    }
    
    
    
    // MARK: - Actions
    
    public func defeated(target: Character) {
        experience += target.experience
    }
    
    
    public func buy(item: Item, seller: Character) throws {
        guard item.value <= gold else {
            throw PurchaseError.notEnoughGold(character: self)
        }
        
        gold -= item.value
        seller.gold += item.value
        seller.inventory.remove(item: item)
        inventory.add(item: item)
    }
    
    
    public func sell(item: Item, to target: Character) throws {
        try target.buy(item: item, seller: self)
    }
    
    
    public func consume(item: Item) throws {
        guard item.isConsumable else { return }
        guard health < 100 else { throw HealError.healthFull }
        let newHealth = health + item.modifier
        health = newHealth > 100 ? 100 : newHealth
    }
    
    
    public func attack(_ target: Character, with type: AttackType) throws -> Int {
        if(type == .melee) {
            return try meleeAttack(target)
        } else {
            return try rangedAttack(target)
        }
    }
    
    
    private func meleeAttack(_ target: Character) throws -> Int {
        guard let weapon = self.inventory.equipped(for: .meleeWeapon) else {
            throw AttackError.noWeaponEquipped(character: self, type: .melee)
        }
        
        return try target.takeDamage(weapon.modifier * strength, from: .melee)
    }
    
    
    private func rangedAttack(_ target: Character) throws -> Int {
        guard let weapon = self.inventory.equipped(for: .rangedWeapon) else {
            throw AttackError.noWeaponEquipped(character: self, type: .ranged)
        }
        
        guard hitCheck else {
            throw AttackError.missed(character: self, target: target)
        }
        
        return try target.takeDamage(weapon.modifier, from: .ranged)
    }
    
    
    public func takeDamage(_ power: Int, from attack: AttackType) throws -> Int {
        if(attack != .ranged && !dodgeCheck) {
            throw DamageError.dodged(character: self)
        }
        
        let power = power - endurance - inventory.armorModifier
        guard power >= 0 else {
            throw DamageError.attackToWeak(character: self)
        }
        
        health = health - power
        guard !isDead else {
            health = 0
            throw DamageError.characterDied(character: self)
        }
        
        return power
    }
    
    
    public func levelUp(_ special: Special) {
        guard needsLevelUp else { return }
        
        switch special {
            case .strength:
                strength += 1
            case .perception:
                perception += 1
            case .endurance:
                endurance += 1
            case .charisma:
                charisma += 1
            case .intelligence:
                intelligence += 1
            case .agility:
                agility += 1
            case .luck:
                luck += 1
        }
        
        experience = experience - experienceRequired
        level += 1
    }
    
}



extension Character {
    
    public enum Special {
        
        case strength
        case perception
        case endurance
        case charisma
        case intelligence
        case agility
        case luck
        
    }
    
    
    public enum AttackType {
        
        case ranged
        case melee
        
        var description: String {
            switch self {
                case .melee: return "melee"
                case .ranged: return "ranged"
            }
        }
        
    }
    
    
    public enum HealError: Error {
        
        case healthFull
        
        public var errorDescription: String {
            switch self {
                case .healthFull:
                    return "Health is full"
            }
        }
    }
    
    
    public enum DamageError: Error {
        
        case attackToWeak(character: Character)
        case characterDied(character: Character)
        case dodged(character: Character)
        
        public var errorDescription: String {
            switch self {
                case .attackToWeak(let character):
                    return "The attack was too weak to damage \(character.name)"
                case .dodged(let character):
                    return "\(character.name) dodged attack"
                case .characterDied(let character):
                    return "\(character.name) died"
            }
        }
    }
    
    
    public enum AttackError: Error {
        
        case missed(character: Character, target: Character)
        case noWeaponEquipped(character: Character, type: AttackType)
        
        public var errorDescription: String {
            switch self {
                case .missed(let character, let target):
                    return "\(character.name) failed to hit \(target.name)"
                case .noWeaponEquipped(let character, let type):
                    return "\(character.name) has no \(type.description) weapon equipped"
            }
        }
    }
    
    
    public enum PurchaseError: Error {
        
        case notEnoughGold(character: Character)
        
        public var errorDescription: String {
            switch self {
                case .notEnoughGold(let character):
                    return "\(character.name) doesn't have enough gold to buy this"
            }
        }
    }
    
}
