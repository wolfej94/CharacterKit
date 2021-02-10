public class Character: Codable {
    
    // MARK: - Variables
    
    enum CodingKeys: String, CodingKey {
        case level = "level"
        case experience = "experience"
        case strength = "strength"
        case perception = "perception"
        case endurance = "endurance"
        case charisma = "charisma"
        case intelligence = "intelligence"
        case agility = "agility"
        case luck = "luck"
        case health = "health"
        case name = "name"
        case gold = "gold"
        case inventory = "inventory"
    }
    
    private(set) var characterLevel: Int
    private(set) var characterExperience: Int
    private(set) var characterStrength: Int
    private(set) var characterPerception: Int
    private(set) var characterEndurance: Int
    private(set) var characterCharisma: Int
    private(set) var characterIntelligence: Int
    private(set) var characterAgility: Int
    private(set) var characterLuck: Int
    private(set) var characterHealth: Int
    private(set) var characterName: String
    private(set) var characterGold: Int
    public let inventory: Inventory
    
    public var level: Int { return characterLevel }
    public var experience: Int { return characterExperience }
    public var strength: Int { return characterStrength }
    public var perception: Int { return characterPerception }
    public var endurance: Int { return characterEndurance }
    public var charisma: Int { return characterCharisma }
    public var intelligence: Int { return characterIntelligence }
    public var agility: Int { return characterAgility }
    public var luck: Int { return characterLuck }
    public var health: Int { return characterHealth }
    public var name: String { return characterName }
    public var gold: Int { return characterGold }
    
    public var experienceRequired: Int {
        if(level == 70) { return 0 }
        let nextLevel = level + 1
        return nextLevel * 100
    }
    
    public var needsLevelUp: Bool {
        return level == 70 ? false : experience >= experienceRequired
    }
    
    public var isDead: Bool {
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
    
    public init(level: Int = 1, experience: Int = 0, strength: Int = 1, perception: Int = 1, endurance: Int = 1, charisma: Int = 1, intelligence: Int = 1, agility: Int = 1, luck: Int = 1, health: Int = 100, name: String, gold: Int = 100, inventory: Inventory? = nil) {
        self.characterLevel = level
        self.characterExperience = experience
        self.characterStrength = strength
        self.characterPerception = perception
        self.characterEndurance = endurance
        self.characterCharisma = charisma
        self.characterIntelligence = intelligence
        self.characterAgility = agility
        self.characterLuck = luck
        self.characterHealth = health
        self.characterName = name
        self.characterGold = gold
        self.inventory = inventory ?? Inventory()
        self.inventory.character = self
    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        characterLevel = try container.decode(Int.self, forKey: .level)
        characterExperience = try container.decode(Int.self, forKey: .experience)
        characterStrength = try container.decode(Int.self, forKey: .strength)
        characterPerception = try container.decode(Int.self, forKey: .perception)
        characterEndurance = try container.decode(Int.self, forKey: .endurance)
        characterCharisma = try container.decode(Int.self, forKey: .charisma)
        characterIntelligence = try container.decode(Int.self, forKey: .intelligence)
        characterAgility = try container.decode(Int.self, forKey: .agility)
        characterLuck = try container.decode(Int.self, forKey: .luck)
        characterHealth = try container.decode(Int.self, forKey: .health)
        characterName = try container.decode(String.self, forKey: .name)
        characterGold = try container.decode(Int.self, forKey: .gold)
        inventory = try container.decode(Inventory.self, forKey: .inventory)
        inventory.character = self
    }
    
    
    
    // MARK: - Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(level, forKey: .level)
        try container.encodeIfPresent(experience, forKey: .experience)
        try container.encodeIfPresent(strength, forKey: .strength)
        try container.encodeIfPresent(perception, forKey: .perception)
        try container.encodeIfPresent(endurance, forKey: .endurance)
        try container.encodeIfPresent(charisma, forKey: .charisma)
        try container.encodeIfPresent(intelligence, forKey: .intelligence)
        try container.encodeIfPresent(agility, forKey: .agility)
        try container.encodeIfPresent(luck, forKey: .luck)
        try container.encodeIfPresent(health, forKey: .health)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(gold, forKey: .gold)
        try container.encodeIfPresent(inventory, forKey: .inventory)
    }
    
    
    
    
    
    
    // MARK: - Actions
    
    public func defeated(target: Character) {
        characterExperience += target.experience
    }
    
    
    public func buy(item: Item, seller: Character) throws {
        guard item.value <= gold else {
            throw PurchaseError.notEnoughGold(character: self)
        }
        
        characterGold -= item.value
        seller.characterGold += item.value
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
        characterHealth = newHealth > 100 ? 100 : newHealth
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
        
        characterHealth = health - power
        guard !isDead else {
            characterHealth = 0
            throw DamageError.characterDied(character: self)
        }
        
        return power
    }
    
    
    public func levelUp(_ special: Special) {
        guard needsLevelUp else { return }
        
        switch special {
            case .strength:
                characterStrength += 1
            case .perception:
                characterPerception += 1
            case .endurance:
                characterEndurance += 1
            case .charisma:
                characterCharisma += 1
            case .intelligence:
                characterIntelligence += 1
            case .agility:
                characterAgility += 1
            case .luck:
                characterLuck += 1
        }
        
        characterExperience = characterExperience - experienceRequired
        characterLevel += 1
    }
    
}



extension Character {
    
    public enum Special: Int {
        
        case strength = 0
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
