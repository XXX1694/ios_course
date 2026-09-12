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


// Medium tasks

var set1: Set<Int>  = [1, 2, 3, 4];
var set2: Set<Int>  = [3, 4, 5, 6];
print(set1.intersection(set2))

var studetGrades: [String: Int] = [
    "Abzal": 90,
    "Arman": 98,
    "Borat": 69,
]
studetGrades["Borat"] = 70
print(studetGrades)

var fruits1: [String] = ["apple", "banana"]
var fruits2: [String] = ["cherry", "date"]
var allFruits: [String] = fruits1 + fruits2
print(allFruits)
