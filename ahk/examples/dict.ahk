myDict := {1: "Value for key 1", 2: "Value for key 2", 3: "Value for key 3"}
MsgBox("myDict: " myDict.1)

myMap := Map(3, "Value for key 3", 2, "Value for key 2", 1, "Value for key 1")
MsgBox("myMap: " myMap[2] "`n" "Count: " myMap.Count)

myMap2 := Map(
    3, Map("Value", "Value for key 3"),
    2, Map("Value", "Value for key 2"),
    1, Map("Value", "Value for key 1")
)
MsgBox("myMap: " myMap2[3]["Value"])
