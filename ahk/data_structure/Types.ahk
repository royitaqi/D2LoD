#Requires AutoHotkey v2.0.0


nil := ""

IsBoolean(x) {
    return x = 1 || x = 0
}

; IsInteger(x)

; IsNumber(x)

IsString(x) {
    return x is String
}

IsArray(x) {
    return x is Array
}

IsGeneralObject(x) {
    return IsObject(x) && !IsArray(x) && !IsMap(x) && !IsFunction(x) && !IsError(x)
}

IsMap(x) {
    return x is Map
}

IsFunction(x) {
    return HasMethod(x)
}

IsError(x) {
    return x is Error
}
