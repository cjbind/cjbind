package cjbind.ir

import std.collection.*

public class ObjCInterface {
    public var name: String
    public var category: ?String = None
    public var isProtocol: Bool = false
    public var templateNames: ArrayList<String> = ArrayList<String>()
    public var conformsTo: ArrayList<ItemId> = ArrayList<ItemId>()
    public var parentClass: ?ItemId = None
    public var methods: ArrayList<ObjCMethod> = ArrayList<ObjCMethod>()
    public var classMethods: ArrayList<ObjCMethod> = ArrayList<ObjCMethod>()
    public var properties: ArrayList<ObjCProperty> = ArrayList<ObjCProperty>()
    public var isForwardDeclaration: Bool = false

    public init(name: String) {
        this.name = name
    }

    public func propertySelectors(): HashSet<String> {
        let selectors = HashSet<String>()
        for (p in this.properties) {
            selectors.add(p.getterName)
            if (let Some(setter) <- p.setterName) {
                selectors.add(setter)
            }
        }
        return selectors
    }

    public func staticClashNames(): HashSet<String> {
        let instanceNames = HashSet<String>()
        for (m in this.methods) {
            instanceNames.add(m.name)
        }
        let clashes = HashSet<String>()
        for (m in this.classMethods) {
            if (instanceNames.contains(m.name)) {
                clashes.add(m.name)
            }
        }
        return clashes
    }

    public func dedupMethods(): Unit {
        this.methods = dedupMethodsBySelector(this.methods)
        this.classMethods = dedupMethodsBySelector(this.classMethods)
    }
}

func dedupMethodsBySelector(methods: ArrayList<ObjCMethod>): ArrayList<ObjCMethod> {
    let seen = HashSet<String>()
    let result = ArrayList<ObjCMethod>()
    for (m in methods) {
        if (!seen.contains(m.selector)) {
            seen.add(m.selector)
            result.add(m)
        }
    }
    return result
}

public class ObjCMethod {
    public let name: String
    public let selector: String
    public let signature: FunctionSig
    public let isClassMethod: Bool
    public let isOptional: Bool
    public let returnsNullable: Bool
    public let nullableParams: ArrayList<Bool>
    public let isInitMethod: Bool

    public init(name: String, selector: String, signature: FunctionSig, isClassMethod!: Bool = false,
                isOptional!: Bool = false, returnsNullable!: Bool = false,
                nullableParams!: ArrayList<Bool> = ArrayList<Bool>(),
                isInitMethod!: Bool = false) {
        this.name = name
        this.selector = selector
        this.signature = signature
        this.isClassMethod = isClassMethod
        this.isOptional = isOptional
        this.returnsNullable = returnsNullable
        this.nullableParams = nullableParams
        this.isInitMethod = isInitMethod
    }

    public func renamedForClassClash(): ObjCMethod {
        ObjCMethod("class_" + this.name, this.selector, this.signature,
            isClassMethod: this.isClassMethod, isOptional: this.isOptional,
            returnsNullable: this.returnsNullable, nullableParams: this.nullableParams,
            isInitMethod: this.isInitMethod)
    }
}

public class ObjCProperty {
    public let name: String
    public let ty: TypeId
    public let getterName: String
    public let setterName: ?String
    public let isClassProperty: Bool
    public let isOptional: Bool
    public let isReadonly: Bool
    public let isNullable: Bool

    public init(name: String, ty: TypeId, getterName: String, setterName!: ?String = None,
                isClassProperty!: Bool = false, isOptional!: Bool = false, isReadonly!: Bool = false,
                isNullable!: Bool = false) {
        this.name = name
        this.ty = ty
        this.getterName = getterName
        this.setterName = setterName
        this.isClassProperty = isClassProperty
        this.isOptional = isOptional
        this.isReadonly = isReadonly
        this.isNullable = isNullable
    }
}
