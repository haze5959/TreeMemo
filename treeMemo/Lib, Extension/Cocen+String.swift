//
//  CocenStringExtension.swift
//  CocenModule
//
//  Created by kwonogyu on 24/06/2019.
//

import Foundation

public extension String {
    
    /**
     서브스트링 간략화
     - Note:
     사용법: "TEST String!"[5..<8] -> "Str"
     */
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
    
    /**
     해당 문자를 가진 범위 가져오기
     - Parameter subString: 찾을 문자열
     - Returns: NSRange or nil
     */
    func getRange(of subString: String) -> NSRange? {
        guard let subStringRange: Range = self.range(of: subString) else {
            return nil
        }
        
        let start: Int = self.distance(from: self.startIndex, to: subStringRange.lowerBound)
        return NSRange(location: start, length: subString.count)
    }
    
    // MARK: Base64
    
    /**
     Base64 변환
     - Parameter None:
     - Returns: Base64 String
     */
    func toBase64() -> String {
        let plainData = (self as NSString).data(using: String.Encoding.utf8.rawValue)
        let base64Data = plainData?.base64EncodedData(options: [])
        
        var returnString = ""
        if let data = base64Data {
            returnString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        }
        
        return returnString
    }
    
    /**
     Base64 해석
     - Parameter None:
     - Returns: 평문
     */
     func fromBase64() -> String {
        let decodedData: Data? = Data(base64Encoded: self, options: [])
        
        var returnString: String = ""
        if let data: Data = decodedData {
            returnString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
        }
        
        return returnString
    }
    
    // MARK: Format Casting & Check
    enum PhoneNumberType {
        case koreanCell
        case koreanPhone
    }
    
    enum PhoneNumberSecretType {
        case none
        case half
        case all
    }
    
    enum NumberFormatType {
        case thousandSeparator
        case dollar
    }
    
    enum PasswordType {
        case normal
        case koreanGovernment
        case koreanGovernmentLow
        case alphabetAndNumber
    }
    
    enum URLEncodeType {
        case query
        case url
        case normal
        case full
    }
    
    /**
     전화번호 포멧으로 변환
     - Parameter type: .koreanCell .koreanPhone
     - Parameter secretType: .none .half .all
     - Returns: 01044932503 -> 010-4493-2503
     */
    func toPhoneNumberFormat(_ type: PhoneNumberType,
                             secretType: PhoneNumberSecretType = .none) -> String {
        var phoneNumber: String = ""
        var formatPhoneNumber = ""
        
        for char in [Character](self) {
            let charToString = String(char)
            if Int(charToString) != nil {
                phoneNumber += charToString
            }
        }
        
        let phoneNumberCount: Int = phoneNumber.count
        formatPhoneNumber = phoneNumber
        
        switch type {
        case .koreanCell:
            var separate1 = ""
            var separate2: String
            var separate3: String
            if phoneNumberCount > 3 {
                
                separate1 = phoneNumber[0..<3]
                separate2 = phoneNumber[3..<phoneNumberCount]
                
                formatPhoneNumber = "\(separate1)-\(separate2)"
            }
            
            if phoneNumberCount > 7 {
                separate2 = phoneNumber[3..<7]
                separate3 = phoneNumber[7..<phoneNumberCount]
                
                formatPhoneNumber = "\(separate1)-\(separate2)-\(separate3)"
            }
            
            if phoneNumberCount == 10 {
                separate2 = phoneNumber[3..<6]
                separate3 = phoneNumber[6..<10]
                
                formatPhoneNumber = "\(separate1)-\(separate2)-\(separate3)"
            }
        case .koreanPhone:
            var separate1Length = 3
            if phoneNumber.hasPrefix("02") {
                separate1Length = 2
            }
            
            var separate1 = ""
            var separate2: String
            var separate3: String
            if phoneNumberCount > separate1Length {
                separate1 = phoneNumber[0..<separate1Length]
                separate2 = phoneNumber[separate1Length..<(phoneNumberCount - separate1Length)]
                
                formatPhoneNumber = "\(separate1)-\(separate2)"
            }
            
            if phoneNumberCount > separate1Length + 4 {
                separate2 = phoneNumber[separate1Length..<separate1Length + 4]
                separate3 = phoneNumber[separate1Length + 4..<(phoneNumberCount - (separate1Length + 4))]
                
                formatPhoneNumber = "\(separate1)-\(separate2)-\(separate3)"
            }
            
            if phoneNumberCount == separate1Length + 3 + 4 {
                separate2 = phoneNumber[separate1Length..<separate1Length + 3]
                separate3 = phoneNumber[(separate1Length + 3)..<(separate1Length + 7)]
                
                formatPhoneNumber = "\(separate1)-\(separate2)-\(separate3)"
            }
        }
        
        if secretType != .none {
            let numberSeparates: [String] = formatPhoneNumber.components(separatedBy: "-")
            if numberSeparates.count > 1 {
                var newSeparate2: String
                if secretType == .half {
                    newSeparate2 = numberSeparates[1][0..<2]
                    let separateCount: Int = numberSeparates[1].count - 2
                    for _ in 0..<separateCount {
                        newSeparate2 += "*"
                    }
                } else {
                    newSeparate2 = ""
                    let separateCount: Int = numberSeparates[1].count
                    for _ in 0..<separateCount {
                        newSeparate2 += "*"
                    }
                }
                
                formatPhoneNumber = numberSeparates[0] + "-" + newSeparate2
                if numberSeparates.count > 2 {
                    formatPhoneNumber += "-" + numberSeparates[2]
                }
            }
        }
        
        return formatPhoneNumber
    }
    
    /**
     화폐 단위로 변환
     - Parameter type: .thousandSeparator .dollar
     - Returns: 123456 -> 123,456.00
     */
    func toNumberFormat(_ type: NumberFormatType = .thousandSeparator) -> String {
        let formatter = NumberFormatter()
        
        switch type {
        case .dollar:
            formatter.numberStyle = NumberFormatter.Style.currency
            formatter.currencyCode = "USD"
            formatter.currencySymbol = ""
        default:
            formatter.numberStyle = NumberFormatter.Style.decimal
        }
        
        var numberString: String?
        if let toInt = Float(self) {
            if let formatString = formatter.string(from: NSNumber(value: toInt)) {
                numberString = formatString
            }
        }
        
        guard let returnString: String = numberString else {
            return ""
        }
        
        return returnString
    }
    
    /**
     이메일 형식인지 체크
     - Parameter None:
     - Returns: Bool
     */
    func isEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$",
                                                options: .caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
        } catch {
            return false
        }
    }
    
    /**
     폰넘버인지 체크
     - Parameter None:
     - Returns: Bool
     */
    func isPhoneNumber() -> Bool {
        return self.isRegex("^(01[016789]{1}|02|0[3-9]{1}[0-9]{1})-?[0-9]{3,4}-?[0-9]{4}$")
    }
    
    /**
     영문 숫자만 들어있는지 체크
     - Parameter None:
     - Returns: Bool
     */
    func isSignId() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z]{1}[A-Z0-9]", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
        } catch {
            return false
        }
    }
    
    /**
     정규식 체크
     - Parameter pattern: 정규식 패턴 ex) "^[A-Z]{1}"
     - Returns: Bool
     */
    func isRegex(_ pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
        } catch {
            return false
        }
    }
    
    /**
     패스워드 체크
     - Parameter type: normal: 영문.숫자.특수문자 허용
     / koreanGovernment:영문.숫자.특수문자 각각 하나씩 포함
     / koreanGovernmentLow:영문.숫자.특수문자 중 2개 이상 포함
     / alphabetAndNumber: 영문.숫자 포함
     - Returns: Bool
     */
    func isPassword(_ type: PasswordType = .normal) -> Bool {
        var isAllow = false
        isAllow = self.isRegex("(?=.*[a-zA-Z]|.*[!@#$%^&*?+=_-~]|.*[0-9]).{1,100}$")
        
        if type == .alphabetAndNumber {
            let isAlphabet: Bool = self.isRegex("[a-z]") || self.isRegex("[A-Z]")
            let isNumber: Bool = self.isRegex("[0-9]")
            if isAlphabet && isNumber {
                return true
            } else {
                return false
            }
        }
        
        if (type == .koreanGovernment || type == .koreanGovernmentLow) && isAllow {
            var checkCount: Int = 0
            if type == .koreanGovernment {
                checkCount = 3
            } else if type == .koreanGovernmentLow {
                checkCount = 2
            }
            
            var isCount = 0
            
            if self.isRegex("[a-z]") {
                isCount += 1
            }
            
            if self.isRegex("[A-Z]") {
                isCount += 1
            }
            
            if self.isRegex("[0-9]") {
                isCount += 1
            }
            
            if self.isRegex("[!,@,#,$,%,^,&,*,?,+,=,_,\\-,~]") {
                isCount += 1
            }
            
            if isCount >= checkCount {
                isAllow = true
            } else {
                isAllow = false
            }
        }
        
        return isAllow
    }
    
    /**
     이모지 포함 체크
     - Parameter None:
     - Returns: Bool
     */
    func containsEmoji() -> Bool {
        return !unicodeScalars.filter { $0.isEmoji }.isEmpty
    }
    
    /**
     영문,숫자,한글 2~12글자 체크
     - Parameter None:
     - Returns: Bool
     */
    func isNickname() -> Bool {
        return self.isRegex("^[A-Za-z0-9ㄱ-ㅎㅏ-ㅣ가-힣]{2,12}$")
    }
    
    /**
     숫자 8자리 체크 및 yyyyMMdd형식 체크
     - Parameter None:
     - Returns: Bool
     */
    func isBirth() -> Bool {
        if !self.isRegex("^[0-9]{8}$") {
            return false
        }
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMdd"
        
        guard let birth: Date = dateFormat.date(from: self) else {
            return false
        }
        
        if birth > Date() {
            return false
        }
        
        return true
    }
    
    /**
     yyyyMMdd 형식이면 yyyy.MM.dd 로 리턴 아니면 그대로 리턴
     */
    func formatBirth() -> String {
        if self.isBirth() {
            var newBirthStr = self
            newBirthStr.insert(".", at: newBirthStr.index(newBirthStr.startIndex, offsetBy: 4))
            newBirthStr.insert(".", at: newBirthStr.index(newBirthStr.endIndex, offsetBy: -2))
            return newBirthStr
        } else {
            return self
        }
    }
    
    /**
     HTML Tag 형식 텍스트를 NSAttributedString으로 변환
     */
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    // MARK: Type Casting
    
    /**
     "true", "yes", "1", "y" 체크
     - Parameter None:
     - Returns: 대소문자 상관없이 "true", "yes", "1", "y"이면 true 리턴
     - Note:
     전혀 다른 값이어도 false 리턴
     */
    func toBool() -> Bool {
        var bool: Bool = false
        let trueStrings: [String] = ["true", "yes", "1", "y"]
        if trueStrings.contains(self.lowercased()) {
            bool = true
        }
        
        return bool
    }
    
    // MARK: URL 관련
    
    /**
     URL Encoding
     - Parameter None:
     - Returns: String or nil
     */
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters
            = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    /**
    URL 인코딩
    - Returns: String
    */
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    /**
     URL String의 Parameter를 Dictionary로 변환
     - Parameter None:
     - Returns: Dictionary
     */
    func urlStringParser() -> [String: String] {
        var parse = [String: String]()
        let urls = self.components(separatedBy: "?")
        var parameterString: String
        
        if urls.count == 2 {
            parameterString = urls[1]
        } else {
            parameterString = urls[0]
        }
        
        let parameters = parameterString.components(separatedBy: "&")
        for parameter in parameters {
            let split = parameter.components(separatedBy: "=")
            if split.count > 1 {
                var value: String = ""
                for integer in 1..<split.count {
                    value += split[integer]
                }
                parse[split[0]] = value
            }
        }
        
        return parse
    }
    
    /**
    공백문자 제거
    - Returns: String
    */
    var trim: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    /**
    UTF-8 인코딩
    - Returns: String
    */
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
    
    /**
    NSLocalizedString 간략화
    */
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension UnicodeScalar {
    var isEmoji: Bool {
        
        switch value {
        case 0x3030, 0x00AE, 0x00A9, // Special Characters
        0x1D000 ... 0x1F77F, // Emoticons
        0x2100 ... 0x27BF, // Misc symbols and Dingbats
        0xFE00 ... 0xFE0F, // Variation Selectors
        0x1F900 ... 0x1F9FF: // Supplemental Symbols and Pictographs
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        return value == 8205
    }
}

extension Date {
    func relativeDaysFromToday() -> String {
        let interval = Date().timeIntervalSince(self)
        let days = Int(interval / 86400)
        print("\(days)일만큼 차이납니다.")
    }
}
