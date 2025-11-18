#Requires AutoHotkey v2.0.0

#include ../Script.ahk
#include ../UnitTest.ahk


Test_Script_RetryCount_SuccessAtHalf() {
    test(n) {
        invocations := 0
        func() {
            invocations := invocations + 1
            if (invocations > n // 2) {
                return invocations
            } else {
                throw Error(invocations)
            }
        }
        ret := RetryCount(func, n, 0)
        Assert(IsInteger(ret))
        AssertEqual(ret, n // 2 + 1)
    }

    n := 1
    loop 5 {
        test(n)
        n := n + 1
    }
}
RunTest(Test_Script_RetryCount_SuccessAtHalf)

Test_Script_RetryCount_FailTillCount() {
    test(n) {
        invocations := 0
        func() {
            invocations := invocations + 1
            throw Error(invocations)
        }
        ret := RetryCount(func, n, 0)
        Assert(IsError(ret))
        AssertEqual(ret.message, string(n))
    }

    n := 1
    loop 5 {
        test(n)
        n := n + 1
    }
}
RunTest(Test_Script_RetryCount_FailTillCount)

Test_Script_RetryTimeout_SuccessAtHalf() {
    test(n) {
        invocations := 0
        func() {
            invocations := invocations + 1
            if (invocations > n // 2) {
                return invocations
            } else {
                throw Error(invocations)
            }
        }
        ret := RetryTimeout(func, n * 100 - 50, 100)
        Assert(IsInteger(ret))
        AssertEqual(ret, n // 2 + 1)
    }

    n := 1
    loop 5 {
        test(n)
        n := n + 1
    }
}
RunTest(Test_Script_RetryTimeout_SuccessAtHalf)

Test_Script_RetryTimeout_FailTillTimeout() {
    test(n) {
        invocations := 0
        func() {
            invocations := invocations + 1
            throw Error(invocations)
        }
        ret := RetryTimeout(func, n * 100 - 50, 100)
        Assert(IsError(ret))
        AssertEqual(ret.message, string(n))
    }

    n := 1
    loop 5 {
        test(n)
        n := n + 1
    }
}
RunTest(Test_Script_RetryTimeout_FailTillTimeout)

ReportPass("Test_Script_Retry.ahk")
