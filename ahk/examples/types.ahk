#Requires AutoHotkey v2.0.0

#include ../data_structure/Types.ahk


TestFunc() {
}

TestTypes(testFunction) {
    output := testFunction.Name ":`n"
    for i, in allValues {
        output := output "`n" allNames[i] ": " testFunction.Call(allValues[i])
    }
    MsgBox output
}

allValues := [true, 2, 3.14, "I'm a string", [1,2,3], {x:1,y:2}, Map(1,2,3,4), TestFunc, Error()]
allNames := ["true", "2", "3.14", "`"I'm a string`"", "[1,2,3]", "{x:1,y:2}", "Map(1,2,3,4)", "TestFunc", "Error()"]

TestTypes(IsBoolean)
TestTypes(IsInteger)
TestTypes(IsNumber)
TestTypes(IsString)
TestTypes(IsArray)
TestTypes(IsGeneralObject)
TestTypes(IsMap)
TestTypes(IsFunction)
TestTypes(IsError)
