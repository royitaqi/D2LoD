#Requires AutoHotkey v2.0.0


; Create an example object
myObject := {
    Field1: "Value A",
    Field2: 123,
    Field3: True,
    AnotherField: "Hello"
}

; Iterate through the object to get all key-value pairs
output := ""
for key, value in myObject.OwnProps()
{
    output .= "Key: " . key . ", Value: " . value . "`n"
}

MsgBox output
