//
//  JBJson.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/12/24.
//

import Foundation

public enum JBJsonError {
    case invalidJSON
    case unsupportedType
    case wrongType
    case indexOutOfBounds
    case notExist
    case elementTooDeep
}

extension JBJsonError: CustomNSError, LocalizedError {
    
    public var localizedDescription: String {
        return "JBJson Error"
    }
    
    public var errorCode: Int {
        switch self {
        case .invalidJSON:
            return 501
        case .unsupportedType:
            return 502
        case .wrongType:
            return 503
        case .indexOutOfBounds:
            return 504
        case .notExist:
            return 505
        case .elementTooDeep:
            return 506
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "格式不符"
        case .unsupportedType:
            return "未支援"
        case .wrongType:
            return "類型錯誤"
        case .elementTooDeep:
            return "物件層級過高"
        case .indexOutOfBounds:
            return "數量錯誤"
        case .notExist:
            return "不存在"
        }
    }
}


public enum Type: Int {
    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case unknown
}


public struct JBJson {
    
    /**
     Create a JBJson using data
     
     ---
     
     - parameter data: The Data used to convert to json. Top level object in data is an Array or Dictionary
     */
    public init(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws {
        let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
        self.init(jsonObject: object)
    }
    
    /**
     Creates a JBJson object
     
     - note:
     Using init(parseJBJsno: String) if you want to parse `String`
     
     - parameter object:       any type object
     */
    public init(_ object: Any) {
        switch object {
        case let object as Data:
            do {
                try self.init(data: object)
            } catch {
                self.init(jsonObject: NSNull())
            }
        default:
            self.init(jsonObject: object)
        }
    }
    
    
    /**
     Parses the JBJson string into JBJson object
     
     - parameter parseJBJson:            json string
     */
    public init(parseJBJson jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            self.init(data)
        } else {
            self.init(NSNull())
        }
    }
    
    
    fileprivate init(jsonObject: Any) {
        self.object = jsonObject
    }
    
    ///private properties
    fileprivate var rawArray: [Any] = []
    fileprivate var rawDictionary: [String: Any] = [:]
    fileprivate var rawString: String = ""
    fileprivate var rawNumber: NSNumber = 0
    fileprivate var rawNull: NSNull = NSNull()
    fileprivate var rawBool: Bool = false
    
    /// JBJson type, fileprivate setting
    public fileprivate(set) var type: Type = .null
    
    public fileprivate(set) var error: JBJsonError?
    
    public var object: Any {
        get {
            switch self.type {
            case .array:
                return self.rawArray
            case .dictionary:
                return self.rawDictionary
            case .string:
                return self.rawString
            case .number:
                return self.rawNumber
            case .bool:
                return self.rawBool
            default:
                return self.rawNull
            }
        }
        set {
            error = nil
            switch unwrap(newValue) {
            case let number as NSNumber:
                if number.isBool {
                    type = .bool
                    self.rawBool = number.boolValue
                } else {
                    type = .number
                    self.rawNumber = number
                }
            case let string as String:
                type = .string
                self.rawString = string
            case _ as NSNull:
                type = .null
            case nil:
                type = .null
            case let array as [Any]:
                type = .array
                self.rawArray = array
            case let dictionary as [String: Any]:
                type = .dictionary
                self.rawDictionary = dictionary
            default:
                type = .unknown
                error = JBJsonError.unsupportedType
            }
            
        }
    }
    
    
    @available(*, unavailable, renamed: "null")
    public static var nullJBJson: JBJson { return null }
    public static var null: JBJson { return JBJson(NSNull()) }
    
}

private func unwrap(_ object: Any) -> Any {
    switch object {
    case let json as JBJson:
        return json.object
    case let array as [Any]:
        return array.map(unwrap)
    case let dictionary as [String: Any]:
        var unwrappedDic = dictionary
        for(key, value) in dictionary {
            unwrappedDic[key] = unwrap(value)
        }
        return unwrappedDic
    default:
        return object
    }
}

public enum Index<T: Any>: Comparable {
    case array(Int)
    case dictionary(DictionaryIndex<String, T>)
    case null
    
    public static func == (lhs: Index, rhs: Index) -> Bool {
        switch (lhs, rhs) {
        case (.array(let left), .array(let right)):
            return left == right
        case (.dictionary(let left), .dictionary(let right)):
            return left == right
        case (.null, .null):
            return true
        default:
            return false
        }
    }

    public static func < (lhs: Index<T>, rhs: Index<T>) -> Bool {
        switch (lhs, rhs) {
        case (.array(let left), .array(let right)):
            return left == right
        case (.dictionary(let left), .dictionary(let right)):
            return left == right
        case (.null, .null):
            return true
        default:
            return false
        }
    }
    
}

public typealias JBJsonIndex = Index<JBJson>
public typealias JBJsonRawIndex = Index<Any>

extension JBJson: Swift.Collection {
    
    public typealias Index = JBJsonRawIndex
    
    public var startIndex: Index {
        switch self.type {
        case .array:
            return .array(rawArray.startIndex)
        case .dictionary:
            return .dictionary(rawDictionary.startIndex)
        default:
            return .null
        }
    }
    
    public var endIndex: Index {
        switch self.type {
        case .array:
            return .array(self.rawArray.endIndex)
        case .dictionary:
            return .dictionary(self.rawDictionary.endIndex)
        default:
            return .null
        }
    }
    
    public func index(after i: Index) -> Index {
        switch i {
        case .array(let index):
            return .array(rawArray.index(after: index))
        case .dictionary(let dict):
            return .dictionary(rawDictionary.index(after: dict))
        default:
            return .null
        }
    }
    
    public subscript (position: Index) -> (String, JBJson) {
        switch position {
        case .array(let index):
            return (String(index), JBJson(self.rawArray[index]))
        case .dictionary(let dictIndex):
            let (key, value) = self.rawDictionary[dictIndex]
            return (key, JBJson(value))
        default:
            return ("", JBJson.null)
        }
    }
    
}

//MARK: - Subscript


public enum JBJsonKey {
    case index(Int)
    case key(String)
}

public protocol JBJsonSubscriptType {
    var jsonKey: JBJsonKey { get }
}

extension Int: JBJsonSubscriptType {
    public var jsonKey: JBJsonKey {
        return JBJsonKey.index(self)
    }
}

extension String: JBJsonSubscriptType {
    public var jsonKey: JBJsonKey {
        return JBJsonKey.key(self)
    }
}

extension JBJson {
    
    fileprivate subscript (index index: Int) -> JBJson {
        get {
            if self.type != .array {
                var r = JBJson.null
                r.error = self.error ?? JBJsonError.wrongType
                return r
            } else if self.rawArray.indices.contains(index) {
                return JBJson.init(jsonObject: self.rawArray[index])
            } else {
                var r = JBJson.null
                r.error = JBJsonError.indexOutOfBounds
                return r
            }
        }
        set {
            if self.type == .array &&
            self.rawArray.indices.contains(index) &&
                newValue.error == nil {
                self.rawArray[index] = newValue.object
            }
        }
    }
    
    
    /**
     Only for `dictionary` type, otherwise return null and error
     */
    fileprivate subscript(key key: String) -> JBJson {
        get {
            var r = JBJson.null
            if self.type == .dictionary {
                if let o = self.rawDictionary[key] {
                    r = JBJson(o)
                } else {
                    r.error = JBJsonError.notExist
                }
            } else {
                r.error = self.error ?? JBJsonError.wrongType
            }
            return r
        }
        set {
            if self.type == .dictionary && newValue.error == nil {
                self.rawDictionary[key] = newValue.object
            }
        }
    }
    
    /**
     If *Int* type, return subscript(index: Int),
     If *String* type return subscript(key: String)
     
     - parameter sub:           JBJsonSubscriptType type
     - returns:                 JBJson type
     */
    fileprivate subscript(sub sub: JBJsonSubscriptType) -> JBJson {
        get {
            switch sub.jsonKey {
            case .index(let index): return self[index: index]
            case .key(let key): return self[key: key]
            }
        }
        set {
            switch sub.jsonKey {
            case .index(let index): self[index: index] = newValue
            case .key(let key): self[key: key] = newValue
            }
        }
    }
    
    /**
     Find a json in the complex data structures by using array of Int and/or String as path.
     
     Example:
     ```
     let json = JBJson[data]
     let path = [9, "list", "persone", "name"]
     let name = json[path]
     ```
     
     - parameter path:         Target json path
     - returns:                Return a json found
     */
    public subscript(path: [JBJsonSubscriptType]) -> JBJson {
        get {
            return path.reduce(self, { $0[sub: $1]} )
        }
        set {
            switch path.count {
            case 0:
                return
            case 1:
                self[sub: path[0]].object = newValue.object
            default:
                var aPath = path
                aPath.remove(at: 0)
                var nextJson = self[sub: path[0]]
                nextJson[aPath] = newValue
                self[sub: path[0]] = nextJson
            }
        }
    }
    
    
    public subscript(path: JBJsonSubscriptType...) -> JBJson {
        get {
            return self[path]
        }
        set {
            self[path] = newValue
        }
    }
    
}

//MARK: -

extension JBJson: Swift.ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
}

extension JBJson: Swift.ExpressibleByDictionaryLiteral {
    public typealias Key = String
    
    public typealias Value = Any
    
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = elements.reduce(into: [Key: Value](), { $0[$1.0] = $1.1 })
        self.init(dictionary)
    }
}

extension JBJson: Swift.ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}


//MARK: -

extension JBJson: Swift.RawRepresentable {
    
    public init?(rawValue: Any) {
        if JBJson(rawValue).type == .unknown {
            return nil
        } else {
            self.init(rawValue)
        }
    }
    
    public var rawValue: Any {
        return self.object
    }
    
    
    public func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> Data {
        guard JSONSerialization.isValidJSONObject(self.object) else {
            throw JBJsonError.invalidJSON
        }
        
        return try JSONSerialization.data(withJSONObject: self.object, options: opt)
    }
    
    public func rawString(_ encoding: String.Encoding = .utf8, option opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        do {
            return try _rawString(encoding, options: [.jsonSerialization: opt])
        } catch {
            print("Could not serialize object to JBJson bacause:", error.localizedDescription)
            return nil
        }
    }
    
    fileprivate func rawString(_ options: [writingOptionKeys: Any]) -> String? {
        let encoding = options[.encoding] as? String.Encoding ?? String.Encoding.utf8
        let maxObjectDepth = options[.maxObjectDepth] as? Int ?? 10
        do {
            return try _rawString(encoding, options: options, maxObjectDepth: maxObjectDepth)
        } catch {
            print("Could not serialize object to JBJson bacause:", error.localizedDescription)
            return nil
        }
    }
    
    
    fileprivate func _rawString(_ encoding: String.Encoding = .utf8, options: [writingOptionKeys: Any], maxObjectDepth: Int = 10) throws -> String? {
        guard maxObjectDepth > 0 else { throw JBJsonError.invalidJSON }
        switch self.type {
        case .dictionary:
            do {
                if !(options[.castNilToNSNull] as? Bool ?? false) {
                    let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
                    let data = try self.rawData(options: jsonOption)
                    return String.init(data: data, encoding: encoding)
                }
                
                guard let dict = self.object as? [String: Any?] else {
                    return nil
                }
                
                let body = try dict.keys.map({ (key) throws -> String in
                    guard let value = dict[key] else {
                        return "\"\(key)\": null"
                    }
                    guard let unwrappedValue = value else {
                        return "\"\(key)\": null"
                    }
                    
                    let nestedValue = JBJson(unwrappedValue)
                    guard let nestedString = try nestedValue._rawString(encoding, options: options, maxObjectDepth: maxObjectDepth - 1) else {
                        throw JBJsonError.elementTooDeep
                    }
                    if nestedValue.type == .string {
                        return "\"\(key)\": \"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
                    } else {
                        return "\"\(key)\": \(nestedString)"
                    }
                })
                
                return "{\(body.joined(separator: ","))}"
            } catch _ {
                return nil
            }
            
        case .array:
            do {
                if !(options[.castNilToNSNull] as? Bool ?? false) {
                    let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
                    let data = try self.rawData(options: jsonOption)
                    return String.init(data: data, encoding: encoding)
                }
                
                guard let array = self.object as? [Any?] else {
                    return nil
                }
                
                let body = try array.map({ (value) throws -> String in
                    guard let unwrappedValue = value else {
                        return "null"
                    }
                    
                    let nestedValue = JBJson(unwrappedValue)
                    guard let nestedString = try nestedValue._rawString(encoding, options: options, maxObjectDepth: maxObjectDepth - 1) else {
                        throw JBJsonError.invalidJSON
                    }
                    
                    if nestedValue.type == .string {
                        return "\"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
                    } else {
                        return nestedString
                    }
                    
                })
                
                return "[\(body.joined(separator: ","))]"
            } catch _ {
                return nil
            }
            
        case .string:
            return self.rawString
        case .number:
            return self.rawNumber.stringValue
        case .bool:
            return self.rawBool.description
        case .null:
            return "null"
        default:
            return nil
        }
    }
}

//MARK: - Array

extension JBJson {
    
    public var array: [JBJson]? {
        if self.type == .array {
            return self.rawArray.map({ JBJson($0) })
        } else {
            return nil
        }
    }
    
    public var arrayValue: [JBJson] {
        return self.array ?? []
    }
    
    public var arrayObject: [Any]? {
        get {
            switch self.type {
            case .array:
                return self.rawArray
            default:
                return nil
            }
        }
        set {
            if let array = newValue {
                self.object = array
            } else {
                self.object = NSNull()
            }
        }
    }
    
}


//MARK: - Dictionary

extension JBJson {
    
    public var dictionary: [String: JBJson]? {
        if self.type == .dictionary {
            var dict = [String: JBJson](minimumCapacity: rawDictionary.count)
            for (key, value) in rawDictionary {
                dict[key] = JBJson.init(value)
            }
            return dict
        } else {
            return nil
        }
    }
    
    
    public var dictionaryValue: [String: JBJson] {
        return dictionary ?? [:]
    }
    
    public var dictionaryObject: [String: Any]? {
        get {
            switch self.type {
            case .dictionary:
                return self.rawDictionary
            default:
                return nil
            }
        }
        set {
            if let new = newValue {
                self.object = new
            } else {
                self.object = NSNull()
            }
        }
    }
    
}

//MARK: - Bool

extension JBJson {
    
    public var bool: Bool? {
        get {
            if self.type == .bool {
                return rawBool
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = newValue as Bool
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var booleanValue: Bool {
        get {
            switch self.type {
            case .bool:
                return self.rawBool
            case .number:
                return self.rawNumber.boolValue
            case .string:
                return ["true", "y", "t", "yes", "1"].contains{
                    self.rawString.caseInsensitiveCompare($0) == .orderedSame
                }
            default:
                return false
            }
        }
        set {
            self.object = newValue
        }
    }
    
    public var boolObject: Any? {
        get {
            switch self.type {
            case .bool:
                return rawBool
            default:
                return nil
            }
        }
        set {
            if let new = newValue {
                self.object = new
            } else {
                self.object = NSNull()
            }
        }
    }
}


//MARK: - String

extension JBJson {
    
    public var string: String? {
        get {
            switch self.type {
            case .string:
                return rawString
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = newValue
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var stringValue: String {
        get {
            switch self.type {
            case .string:
                return self.object as? String ?? ""
            case .number:
                return self.rawNumber.stringValue
            case .bool:
                return (self.object as? Bool).map({ String($0) }) ?? ""
            default:
                return ""
            }
        }
        set {
            self.object = NSString(string: newValue)
        }
    }
    
    public var stringObject: Any? {
        get {
            switch self.type {
            case .string:
                return rawString
            default:
                return nil
            }
        }
        set {
            if let new = newValue {
                self.object = new
            } else {
                self.object = NSNull()
            }
        }
    }
    
    
}

//MARK: - NSNumber

extension JBJson {
    
    public var number: NSNumber? {
        switch self.type {
        case .number:
            return rawNumber
        case .bool:
            return NSNumber(value: self.rawBool ? 1 : 0)
        default:
            return nil
        }
    }
    
    
    public var numberValue: NSNumber {
        get {
            switch self.type {
            case .string:
                // 轉文字小數點
                let decimal = NSDecimalNumber(string: self.object as? String)
                if decimal == NSDecimalNumber.notANumber {
                    return NSDecimalNumber.zero
                }
                return decimal
            case .number:
                return self.object as? NSNumber ?? NSNumber(value: 0)
            case .bool:
                return NSNumber(value: self.rawBool ? 1 : 0)
            default:
                return NSNumber(value: 0.0)
            }
        }
        set {
            self.object = newValue
        }
    }
    
    
    
}



private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(cString: trueNumber.objCType)
private let falseObjCType = String(cString: falseNumber.objCType)

extension NSNumber {
    fileprivate var isBool: Bool {
        let objCType = String.init(cString: self.objCType)
        if (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) ||
            (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType) {
            return true
        } else {
            return false
        }
    }
}

func == (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == .orderedSame
    }
}

func >= (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != .orderedAscending
    }
}

func <= (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool){
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != .orderedDescending
    }
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool){
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == .orderedAscending
    }
}

func > (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool){
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == .orderedDescending
    }
}

public enum writingOptionKeys {
    case jsonSerialization
    case castNilToNSNull
    case maxObjectDepth
    case encoding
}


//MARK: Int

extension JBJson {
    
    public var double: Double? {
        get {
            return self.number?.doubleValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var doubleValue: Double {
        get {
            return self.numberValue.doubleValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var float: Float? {
        get {
            return self.number?.floatValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var floatValue: Float {
        get {
            return self.numberValue.floatValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var int: Int? {
        get {
            return self.number?.intValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var intValue: Int {
        get {
            return self.numberValue.intValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var uInt: UInt? {
        get {
            return self.number?.uintValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var uIntValue: UInt {
        get {
            return self.numberValue.uintValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var int8: Int8? {
        get {
            return self.number?.int8Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: Int(newValue))
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int8Value: Int8 {
        get {
            return self.numberValue.int8Value
        }
        set {
            self.object = NSNumber(value: Int(newValue))
        }
    }
    
    public var uInt8: UInt8? {
        get {
            return self.number?.uint8Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt8Value: UInt8 {
        get {
            return self.numberValue.uint8Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var int16: Int16? {
        get {
            return self.number?.int16Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int16Value: Int16 {
        get {
            return self.numberValue.int16Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var uInt16: UInt16? {
        get {
            return self.number?.uint16Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt16Value: UInt16 {
        get {
            return self.numberValue.uint16Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var int32: Int32? {
        get {
            return self.number?.int32Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int32Value: Int32 {
        get {
            return self.numberValue.int32Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var uInt32: UInt32? {
        get {
            return self.number?.uint32Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt32Value: UInt32 {
        get {
            return self.numberValue.uint32Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var int64: Int64? {
        get {
            return self.number?.int64Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int64Value: Int64 {
        get {
            return self.numberValue.int64Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
    
    public var uInt64: UInt64? {
        get {
            return self.number?.uint64Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt64Value: UInt64 {
        get {
            return self.numberValue.uint64Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
}

// MARK: - Null

extension JBJson {
    
    public var null: NSNull? {
        get {
            switch self.type {
            case .null:
                return self.rawNull
            default:
                return nil
            }
        }
        set {
            self.object = NSNull()
        }
    }
    public func exists() -> Bool {
        if let errorValue = error, (400...1000).contains(errorValue.errorCode) {
            return false
        }
        return true
    }
}

//MARK: - Debug

extension JBJson: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        if let string = self.rawString(option: .prettyPrinted) {
            return "JBJson start: \n" + string + "\nJBJson end😚"
        } else {
            return "取不到"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
}

public extension String {
    /**
     - Remark:
     轉類型至 JSON
     
     - throws: Transform data to JSON formate error
     */
    func transformToJSONFormate() throws -> JBJson? {
        if let data : Data = self.data(using: String.Encoding.utf8) {
            do {
                return try JBJson(data : data)
            } catch  {
                throw error
            }
        } else {
            return nil
        }
    }
}
