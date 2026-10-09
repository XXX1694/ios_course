// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// class because drone and everyone who checks it must see same battery not a copy
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 || amount > charge {
            return false
        }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        if amount <= 0 {
            return
        }
        charge = min(charge + amount, 100)
    }
}

let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// final means no subclass can change runOnce() so every drone pays power before working
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    var canWork: Bool {
        cell.level() >= powerCost
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else {
            return 0
        }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }

    override func performTask() -> Int { 15 }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int { 25 }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: unknown drone kind '\(record.kind)' for \(record.id), skipped")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.canWork {
        C += 1
    }
}
print("Drones ready for one more task: \(C)")


// MARK: Level 4 · Diagnostics

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Drone is class, its methods can always change the object so mutating not needed
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }

    var statusCode: Int { healthCode(for: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }

    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        if amount <= 0 {
            return
        }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// [Drone] holds only Drone and subclasses, SensorModule is struct and cant inherit from Drone
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== DIAGNOSTICS ==="
    for component in components {
        report += "\n" + component.diagnose()
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    func healthCode(for level: Int) -> Int {
        if level < 20 {
            return 2
        }
        if level < 50 {
            return 1
        }
        return 0
    }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String { name }

    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        "[LEGACY] beacon \(name), signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}

extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        var bar = ""
        for i in 0..<10 {
            bar += i < filled ? "#" : "."
        }
        return bar
    }
}


// MARK: Level 6 · Incident Reports

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

/*
 Report 1
 Expected: PatchDrone makes 30 work units
 Actual: dont compile - "overriding declaration requires an 'override' keyword"
 Rule: if subclass replaces parent method it must write override
 Fix: override func performTask() -> Int { 30 }

 Report 2
 Expected: HeavyWelder returns 999 every shift
 Actual: dont compile - WelderDrone is final so nobody can inherit from it
 and runOnce() is final so nobody can override it
 Rule: final blocks subclassing and overriding
 Fix: inherit from Drone and override powerCost and performTask() not runOnce()

 Report 3
 Expected: prints welder message
 Actual: dont compile - "value of type 'Drone' has no member 'weldSeam'"
 Rule: compiler knows only the type in array (Drone), not the real object
 Fix: check at runtime with as? (code below)
 as? returns optional because object may be not WelderDrone, then you get nil

 Report 4
 Expected: "thruster T-1"
 Actual: compiles but prints "generic component"
 Rule: label() is not in protocol, its only in extension. for
 value of type Labelled swift picks extension version not the structs one
 Fix: add one line to protocol: func label() -> String
*/

let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}

protocol Labelled {
    var componentID: String { get }
    func label() -> String
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// runtime: base method crashes if subclass forgot to override it
class RuntimeBaseDrone {
    func performTask() -> Int {
        fatalError("RuntimeBaseDrone must not be used directly, override performTask()")
    }
}

// compile time: protocol cant be created with () and every type must write performTask()
protocol FleetUnit {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension FleetUnit {
    func runOnce() -> Int {
        guard cell.spend(powerCost) else {
            return 0
        }
        return performTask()
    }
}

struct BonusWelderDrone: FleetUnit {
    let id: String
    let cell: PowerCell
    let powerCost = 25

    func performTask() -> Int { 40 }
}

let bonusFleet: [FleetUnit] = [BonusWelderDrone(id: "BW-1", cell: PowerCell(charge: 60))]
var bonusWork = 0
for unit in bonusFleet {
    bonusWork += unit.runOnce()
}
print("Bonus fleet work: \(bonusWork)")

// class version shares code and properties through parent and can lock
// runOnce() with final. protocol version cant be used "bare" and works for structs too
// but anyone can write own runOnce(). for this station id keep class - drones share
// one battery that changes, and with classes everyone sees same object not a copy


