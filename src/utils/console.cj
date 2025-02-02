package cjbind.utils

@When[os == "Windows"]
foreign func SetConsoleOutputCP(codepage: UInt32): Bool

@When[os == "Windows"]
public func updateConsole() {
    unsafe {
        let ret = SetConsoleOutputCP(65001)
        if (!ret) {
            throw Exception("SetConsoleOutputCP failed")
        }
    }
}

@When[os != "Windows"]
public func updateConsole() {
}