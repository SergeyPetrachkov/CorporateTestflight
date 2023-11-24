import Foundation

public enum HttpRequestHeaderKeys: String {
    case authorization = "Authorization"
    case bearer = "Bearer"
    case basic = "Basic"
    case contentType = "Content-Type"
    case xRequestedWith = "X-Requested-With"
    case xmlHttpRequest = "XMLHttpRequest"
    case accept = "Accept"
    case xAppleWidgetKey = "X-Apple-Widget-Key"
    case deviceModel = "X-Device-Model"
    case iosVersion = "X-OS-Version"
    case appVersion = "X-App-Version"
}
