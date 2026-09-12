// Easy tasks

var fruits: [String] = ["apple", "banana", "cherry", "orange", "pineapple"]
print(fruits[2])

var favNums: Set<Int> = [1, 2, 3, 4, 5]
favNums.insert(6)
print(favNums)

var progLang: [String: Int] = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995,
    "C++": 1985,
    "JavaScript": 1995,
]
print(progLang["Swift"] ?? 2014)

var colors: [String] = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print(colors)
