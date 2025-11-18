#Requires AutoHotkey v2.0.0


nil := ""

IsBoolean(x) {
    return x = true || x = false
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

ToString(x) {
    if (IsError(x)) {
        return "[" x.what "] " x.message
    } if (IsFunction(x)) {
        if (x.Name) {
            return x.Name
        } else {
            return "lambda"
        }
    } else {
        return string(x)
    }
}
