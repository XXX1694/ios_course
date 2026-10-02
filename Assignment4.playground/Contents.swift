// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

print("\n=== Level 1 ===")

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass / 500, 0), 3)
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 4000))


// MARK: Level 2 · The Manifest

print("\n=== Level 2 ===")

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)

    switch parts[0] {
    case "crate":
        if parts.count == 3, let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
    case "container":
        if parts.count == 3, let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
    case "livestock":
        if parts.count == 4, let count = Int(parts[2]), let perUnit = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
        }
    default:
        break
    }

    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    print(entry, "->", mass(of: entry), "kg")
    totalMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}

print("Total mass: \(totalMass) kg")
print("Unknown lines: \(unknownCount)")

let A = totalMass


// MARK: Level 3 · Crew Snapshots

print("\n=== Level 3 ===")

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(oxygen - amount, 0)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var rookie = CrewSnapshot.rookie(named: "Arman")
print("Rookie: \(rookie)")
rookie.breathe(130)
rookie.move(to: .cargo)
print("After breathe and move: \(rookie)")
rookie.reviveInMedbay()
print("After revive: \(rookie)")

// 3.2
var crewRoster: [CrewSnapshot] = []

for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    } else {
        print("Warning: \(record.name) is on unknown deck \"\(record.deck)\", skipped")
    }
}

for member in crewRoster {
    print("\(member.name) - \(member.deck.rawValue) - oxygen \(member.oxygen)")
}

// 3.3
func drainPlain(_ crew: CrewSnapshot) {
    var crew = crew
    crew.breathe(50)
    print("   inside plain function: \(crew.oxygen)")
}

func drainInout(_ crew: inout CrewSnapshot) {
    crew.breathe(50)
}

var original = CrewSnapshot(name: "Aigerim", deck: .bridge, oxygen: 91)

var copy = original
print("1. Copy - before: original \(original.oxygen), copy \(copy.oxygen)")
copy.breathe(30)
print("1. Copy - after:  original \(original.oxygen), copy \(copy.oxygen)")

print("2. Plain - before: original \(original.oxygen)")
drainPlain(original)
print("2. Plain - after:  original \(original.oxygen)")

print("3. Inout - before: original \(original.oxygen)")
drainInout(&original)
print("3. Inout - after:  original \(original.oxygen)")


// MARK: Level 4 · The Teleport Pod

print("\n=== Level 4 ===")

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Structs get a memberwise init for free. Classes don't, because a class
    // can be inherited and Swift wants the author to decide how it is initialized.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    deinit {
        print("Pod \(id) deinit")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let crew = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return crew
    }
}

// 4.2
let pod1 = TeleportPod(id: "P-1", chargeLevel: 100)

for name in ["Timur", "Dana", "Nurlan"] {
    for member in crewRoster where member.name == name {
        let loaded = pod1.load(member)
        let arrived = pod1.fire()
        print("Load \(name): \(loaded), fired: \(arrived?.name ?? "nobody"), charge: \(pod1.chargeLevel)")
    }
}

let emptyFire = pod1.fire()
print("Empty fire: \(emptyFire?.name ?? "nobody"), charge: \(pod1.chargeLevel)")

let C = pod1.chargeLevel

// 4.3
let podRef1 = TeleportPod(id: "R-1", chargeLevel: 100)
let podRef2 = podRef1
podRef2.chargeLevel = 30
print("Pod: podRef1 \(podRef1.chargeLevel), podRef2 \(podRef2.chargeLevel)")

var crew1 = CrewSnapshot.rookie(named: "Dana")
var crew2 = crew1
crew2.oxygen = 30
print("Crew: crew1 \(crew1.oxygen), crew2 \(crew2.oxygen)")

// class gives same object to both names, struct gives each one its own copy


// MARK: Level 5 · Station Systems

print("\n=== Level 5 ===")

// 5.1
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int] = [:]

    var hullIntegrity: Int {
        willSet {
            print("Hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(callSign): hull \(hullIntegrity), total oxygen \(totalOxygen)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty {
                return 0
            }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            }
        }
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 100)
let B = station.averageOxygen

print("Total oxygen: \(station.totalOxygen)")
print("Average oxygen: \(station.averageOxygen)")

print("Before first diagnostics access")
print(station.fullDiagnostics)
print("Second access:")
print(station.fullDiagnostics)

let backupStation = Station(callSign: "ALMA-8", hullIntegrity: 80)
print("\(backupStation.callSign) created, diagnostics never touched - no scan printed")

station.averageOxygen = 70
print("After setting average to 70: total \(station.totalOxygen), average \(station.averageOxygen)")

// 5.2
station.hullIntegrity = 130
print("Hull: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("Hull: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("Hull: \(station.hullIntegrity)")

// setting property inside its own didSet doesnt call didSet again
// so clamp works one time and stops


// MARK: Level 6 · Incident Reports

print("\n=== Level 6 ===")

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// Report 1
// Expected: every crew member loses 10 oxygen, Actual: roster dont change
// Rule: for var member gives copy of each struct, the copy changes not the array
do {
    var roster = crewRoster
    for i in roster.indices {
        roster[i].oxygen -= 10
    }
    print("Report 1 fixed: \(roster[0].oxygen)")
}

// Report 2
// Expected: podA keeps 100, Actual: prints 0
// Rule: class is reference type so podA and podB is same object
do {
    let podA = TeleportPod(id: "A", chargeLevel: 100)
    let podB = TeleportPod(id: "A-copy", chargeLevel: podA.chargeLevel)
    podB.chargeLevel = 0
    print("Report 2 fixed: \(podA.chargeLevel)")
}

// Report 3
// Expected: add() adds entry, Actual: dont compile
// "cannot use mutating member on immutable value: 'self' is immutable"
// Rule: struct methods cant change properties without mutating
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()
logbook.add("Day ten: teleporter incident")
print("Report 3 fixed: \(logbook.entries)")

// Report 4
// Expected: both work, Actual: snapshot.oxygen = 40 dont compile
// but pod.chargeLevel = 10 works
// Rule: let on struct freezes whole value with all properties
// let on class freezes only reference, the object itself still can change
do {
    var snapshot = CrewSnapshot.rookie(named: "Dana")
    snapshot.oxygen = 40
    print("Report 4 fixed: \(snapshot.oxygen)")

    let pod = TeleportPod(id: "B", chargeLevel: 50)
    pod.chargeLevel = 10
    print("Report 4 pod: \(pod.chargeLevel)")
}


// MARK: Level 7 · Sealing the Black Box

print("\n=== Level 7 ===")

final class FlightRecorder {
    // private: nobody outside can replace or clear the entries
    private var entries: [String] = []

    // private(set): outside can read isSealed but can't set it back to false
    private(set) var isSealed = false

    // internal: read-only count, can't be used to change anything
    internal var entryCount: Int {
        entries.count
    }

    // internal: read-only transcript, gives text, not the array
    internal var transcript: String {
        var text = ""
        for (index, entry) in entries.enumerated() {
            text += "\(index + 1). \(entry)\n"
        }
        return text
    }

    // internal: the only way to add, blocks adding after seal
    internal func add(_ entry: String) -> Bool {
        if isSealed {
            return false
        }
        entries.append(entry)
        return true
    }

    // internal: can only seal, there is no unseal
    internal func seal() {
        isSealed = true
    }

    // fileprivate: blocks code outside this file from reading raw entries
    fileprivate func rawEntries() -> [String] {
        entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    var lengths = 0
    for entry in recorder.rawEntries() {
        lengths += entry.count
    }
    return "Audit: \(recorder.entryCount) entries, \(lengths) characters, sealed: \(recorder.isSealed)"
}

let recorder = FlightRecorder()
print(recorder.add("Teleporter online"))
print(recorder.add("Crew transfer reported"))
recorder.seal()
print(recorder.add("Rewrite history"))
print("Entries: \(recorder.entryCount)")
print(recorder.transcript)
print(auditTranscript(of: recorder))

// Trying to break it:
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

print("\n=== Finale ===")

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

print("\n=== Bonus ===")

var survivor: TeleportPod?

do {
    let tempPod = TeleportPod(id: "TEMP", chargeLevel: 10)
    survivor = tempPod
    print("Inside do block")
}
print("Left do block - no deinit, survivor still holds the pod")
survivor = nil
print("survivor = nil - deinit fired on the line above")

// after the block only tempPod is gone, survivor still holds it so count is 1
// deinit fires when last reference goes away: survivor = nil

func describe(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "same pod"
    }
    if first.id == second.id && first.chargeLevel == second.chargeLevel {
        return "two pods with equal contents"
    }
    return "different pods"
}

let record1 = TeleportPod(id: "X", chargeLevel: 60)
let record2 = record1
let record3 = TeleportPod(id: "X", chargeLevel: 60)
print(describe(record1, record2))
print(describe(record1, record3))

// === checks if two references is same object. CrewSnapshot is struct
// it has no identity, every variable has own copy so === cant be used


