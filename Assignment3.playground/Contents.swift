// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
 func parseReading(_ raw: String) -> Reading? {
     guard let (sensor, valueStr) = splitOnce(raw, by: ":"),
               !sensor.isEmpty,
               let value = Int(valueStr),
               value >= 0 || sensor == "TEMP" else {
             return nil
         }
     return (sensor, value)
 }

// 1.2
 func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
     var valid: [Reading] = []
     var invalidCount = 0
     for line in lines {
         if let reading = parseReading(line) {
             valid.append(reading)
         } else {
             invalidCount += 1
         }
     }
     return (valid, invalidCount)
 }

let parsedData = parseLog(rawLog)
let A = parsedData.invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard !values.isEmpty else { return nil }
    var minVal = values[0]
    var maxVal = values[0]
    var sum = 0
    
    for v in values {
        if v < minVal { minVal = v }
        if v > maxVal { maxVal = v }
        sum += v
    }
    return (minVal, maxVal, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

let o2Readings = select(parsedData.valid) { $0.sensor == "O2" }
let B = Int(stats(of: values(of: o2Readings))?.average ?? 0)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)

var validReadings = parsedData.valid

let sort1 = validReadings.sorted(by: { (r1: Reading, r2: Reading) -> Bool in return r1.value > r2.value })
let sort2 = validReadings.sorted(by: { r1, r2 in return r1.value > r2.value })
let sort3 = validReadings.sorted(by: { r1, r2 in r1.value > r2.value })
let sort4 = validReadings.sorted(by: { $0.value > $1.value })
let sort5 = validReadings.sorted { $0.value > $1.value }


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    
    while steps < maxSteps {
        if temp >= 18 && temp <= 24 {
            return (temp, steps, true)
        }
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (temp, steps, temp >= 18 && temp <= 24)
}

let tempReadings = select(parsedData.valid) { $0.sensor == "TEMP" }
let minTemp = stats(of: values(of: tempReadings))?.min ?? 0
let C = runUntilStable(from: minTemp).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let module = member.module else {
        return "\(member.name): no data (open space)"
    }
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(module.name))"
    }
    return level < 20 ? "\(member.name): \(level)% CRITICAL" : "\(member.name): \(level)% OK"
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let transfer = min(amount, source, 100 - target)
    source -= transfer
    target += transfer
    return transfer
}

var labLevel = lab.oxygenTank?.level ?? 0
var habLevel = hab.oxygenTank?.level ?? 0
transferOxygen(from: &labLevel, to: &habLevel, amount: 30)
lab.oxygenTank?.level = labLevel
hab.oxygenTank?.level = habLevel

let D = hab.oxygenTank?.level ?? 0

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    
    let sorted = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in sorted {
        result.append(member.name)
    }
    return result
}


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.


func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): No tank available"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

print(reportOxygen(for: crew[1])) // Dana (нет бака)
print(firstCritical(in: crew) ?? "No critical levels")


