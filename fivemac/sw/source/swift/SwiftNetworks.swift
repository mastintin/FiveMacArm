import SwiftUI
import Foundation
import Network
#if canImport(Darwin)
import Darwin
#endif

// Almacén estático para las cabeceras personalizadas (Compartido en la Isla)
public struct SwNetworkConfig {
    public static var customHeaders: [String: String] = [:]
}

//----------------------------------------------------------------------------//

public func sw_getIP() -> String {
    var address: String?
    var ifarg: UnsafeMutablePointer<ifaddrs>?
    
    guard getifaddrs(&ifarg) == 0, let firstAddr = ifarg else { return "0.0.0.0" }
    
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        let addr = ptr.pointee.ifa_addr.pointee
        
        if addr.sa_family == UInt8(AF_INET) && (flags & IFF_LOOPBACK) == 0 {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                address = String(cString: hostname)
                break
            }
        }
    }
    freeifaddrs(ifarg)
    return address ?? "0.0.0.0"
}

//----------------------------------------------------------------------------//

public func sw_http_set_header(key: String, value: String) {
    if value.isEmpty {
        SwNetworkConfig.customHeaders.removeValue(forKey: key)
    } else {
        SwNetworkConfig.customHeaders[key] = value
    }
}

//----------------------------------------------------------------------------//

public func sw_http_clear_headers() {
    SwNetworkConfig.customHeaders.removeAll()
}

//----------------------------------------------------------------------------//

public func sw_isConnected() -> Bool {
    let monitor = NWPathMonitor()
    let semaphore = DispatchSemaphore(value: 0)
    var isConnected = false
    
    monitor.pathUpdateHandler = { path in
        isConnected = (path.status == .satisfied)
        semaphore.signal()
    }
    
    let queue = DispatchQueue(label: "NetMonitor")
    monitor.start(queue: queue)
    
    _ = semaphore.wait(timeout: .now() + 0.2)
    monitor.cancel()
    
    return isConnected
}

//----------------------------------------------------------------------------//

public func sw_http_get(url: String, timeout: Double) async -> String {
    return await sw_perform_request(url: url, method: "GET", body: nil, timeout: timeout)
}

public func sw_http_post(url: String, json: String, timeout: Double) async -> String {
    return await sw_perform_request(url: url, method: "POST", body: json, timeout: timeout)
}

public func sw_http_put(url: String, json: String, timeout: Double) async -> String {
    return await sw_perform_request(url: url, method: "PUT", body: json, timeout: timeout)
}

public func sw_http_delete(url: String, timeout: Double) async -> String {
    return await sw_perform_request(url: url, method: "DELETE", body: nil, timeout: timeout)
}

//----------------------------------------------------------------------------//

public func sw_perform_request(url: String, method: String, body: String?, timeout: Double) async -> String {
    guard let urlObj = URL(string: url) else { return "" }
    
    let realTimeout = timeout > 0 ? timeout : 30.0
    var request = URLRequest(url: urlObj)
    request.httpMethod = method
    request.timeoutInterval = realTimeout
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36", forHTTPHeaderField: "User-Agent")
    
    for (key, value) in SwNetworkConfig.customHeaders {
        request.setValue(value, forHTTPHeaderField: key)
    }

    if let b = body {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = b.data(using: .utf8)
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8) ?? ""
    } catch {
        print("Network Request Error: \(error)")
        return ""
    }
}

public func sw_http_can_resume(url: String) async -> Bool {
    guard let urlObj = URL(string: url) else { return false }
    var request = URLRequest(url: urlObj)
    request.httpMethod = "HEAD"
    for (key, value) in SwNetworkConfig.customHeaders {
        request.setValue(value, forHTTPHeaderField: key)
    }
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if let acceptRanges = httpResponse.allHeaderFields["Accept-Ranges"] as? String {
                return acceptRanges.lowercased() == "bytes"
            }
        }
    } catch {
        print("CanResume Error: \(error)")
    }
    return false
}

//----------------------------------------------------------------------------//

public func sw_http_upload(url: String, filePath: String, timeout: Double) async -> Bool {
    guard let urlObj = URL(string: url) else { return false }
    let fileURL = URL(fileURLWithPath: (filePath as NSString).expandingTildeInPath)
    guard FileManager.default.fileExists(atPath: fileURL.path) else { return false }
    
    let realTimeout = timeout > 0 ? timeout : 60.0
    var request = URLRequest(url: urlObj)
    request.httpMethod = "POST"
    request.timeoutInterval = realTimeout
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    
    for (key, value) in SwNetworkConfig.customHeaders {
        request.setValue(value, forHTTPHeaderField: key)
    }

    do {
        let (_, _) = try await URLSession.shared.upload(for: request, fromFile: fileURL)
        return true
    } catch {
        print("Upload Error: \(error)")
        return false
    }
}

//----------------------------------------------------------------------------//

public func sw_http_download(url: String, destination: String, id: String = "", targetId: String = "", resumePath: String = "", timeout: Double) async -> Bool {
    guard let urlObj = URL(string: url) else { return false }
    let destURL = URL(fileURLWithPath: (destination as NSString).expandingTildeInPath)
    let realTimeout = timeout > 0 ? timeout : 60.0

    let completion: @Sendable (URL?, URLResponse?, Error?) -> Void = { location, response, error in
        var success = false
        if let loc = location {
            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.moveItem(at: loc, to: destURL)
                success = true
                try? FileManager.default.removeItem(atPath: destination + ".resume")
            } catch {
                print("Download Finish Error: \(error)")
            }
        } else if let err = error {
             if let data = (err as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                 try? data.write(to: URL(fileURLWithPath: destination + ".resume"))
             }
        }
        
        if !id.isEmpty {
            let notifyId = targetId.isEmpty ? id : targetId
            let update: [String: Any] = [notifyId: [id: success]]
            if let data = try? JSONSerialization.data(withJSONObject: update),
               let json = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    Harbour.call("SW_PIPELINE_SYNC", json)
                }
            }
        }
    }

    var task: URLSessionDownloadTask
    if !resumePath.isEmpty, let resumeData = try? Data(contentsOf: URL(fileURLWithPath: resumePath)) {
        task = URLSession.shared.downloadTask(withResumeData: resumeData, completionHandler: completion)
    } else {
        var request = URLRequest(url: urlObj)
        request.timeoutInterval = realTimeout
        for (key, value) in SwNetworkConfig.customHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        task = URLSession.shared.downloadTask(with: request, completionHandler: completion)
    }
    
    task.resume()
    return true
}

// MARK: - Dispatcher Bridge (Commands Implementation)

internal struct NetworkCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("httpget")        { params in return ["result": await NetworkCommands.get(params)] }
        sd.register("httppost")       { params in return ["result": await NetworkCommands.post(params)] }
        sd.register("httpput")        { params in return ["result": await NetworkCommands.put(params)] }
        sd.register("httpdelete")     { params in return ["result": await NetworkCommands.delete(params)] }
        sd.register("httpdownload")   { params in return ["result": await NetworkCommands.download(params)] }
        sd.register("httpheader")     { params in NetworkCommands.setHeader(params); return nil }
        sd.register("httpclear")      { params in NetworkCommands.clearHeaders(params); return nil }
        sd.register("httpupload")     { params in return ["result": await NetworkCommands.upload(params)] }
        sd.register("httpcanresume")  { params in return ["result": await NetworkCommands.canResume(params)] }
        sd.register("getip")          { params in 
            let ip = await NetworkCommands.getIP(params)
            print("🏝️ [Networks] Comando 'getip' ejecutado. Resultado: \(ip)")
            return ["result": ip] 
        }
        sd.register("isconnected")    { params in return ["result": await NetworkCommands.isConnected(params)] }
    }

    @discardableResult
    static func performNetworkOperation(params: [String: Any], id: String, targetId: String, method: String) async -> String {
        let urlString = params["url"] as? String ?? ""
        let json = params["json"] as? String ?? ""
        
        var result = ""
        switch method {
        case "GET": result = await sw_http_get(url: urlString, timeout: 60)
        case "POST": result = await sw_http_post(url: urlString, json: json, timeout: 60)
        case "PUT": result = await sw_http_put(url: urlString, json: json, timeout: 60)
        case "DELETE": result = await sw_http_delete(url: urlString, timeout: 60)
        default: break
        }
        
        let key = "last_http_\(method.lowercased())_response"
        SwWorkflowContext.shared.set(result, for: key)
        
        if !id.isEmpty {
            let notifyId = targetId.isEmpty ? id : targetId
            let update: [String: Any] = [notifyId: [id: result]]
            if let data = try? JSONSerialization.data(withJSONObject: update),
               let json = String(data: data, encoding: .utf8) {
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        }
        return result
    }

    @discardableResult
    static func get(_ params: [String: Any]) async -> String {
        let id = params["id"] as? String ?? ""
        let targetId = params["targetId"] as? String ?? ""
        return await performNetworkOperation(params: params, id: id, targetId: targetId, method: "GET")
    }
    
    @discardableResult
    static func post(_ params: [String: Any]) async -> String {
        let id = params["id"] as? String ?? ""
        let targetId = params["targetId"] as? String ?? ""
        return await performNetworkOperation(params: params, id: id, targetId: targetId, method: "POST")
    }

    @discardableResult
    static func put(_ params: [String: Any]) async -> String {
        let id = params["id"] as? String ?? ""
        let targetId = params["targetId"] as? String ?? ""
        return await performNetworkOperation(params: params, id: id, targetId: targetId, method: "PUT")
    }

    @discardableResult
    static func delete(_ params: [String: Any]) async -> String {
        let id = params["id"] as? String ?? ""
        let targetId = params["targetId"] as? String ?? ""
        return await performNetworkOperation(params: params, id: id, targetId: targetId, method: "DELETE")
    }

    @discardableResult
    static func download(_ params: [String: Any]) async -> Bool {
        let url  = (params["url"] as? String) ?? ""
        let dest = (params["path"] as? String) ?? ""
        let id   = (params["id"] as? String) ?? ""
        let targetId = (params["targetId"] as? String) ?? ""
        let resume = (params["resumePath"] as? String) ?? ""
        
        return await sw_http_download(url: url, destination: dest, id: id, targetId: targetId, resumePath: resume, timeout: 60)
    }

    @discardableResult
    static func upload(_ params: [String: Any]) async -> Bool {
        let url  = (params["url"] as? String) ?? ""
        let path = (params["path"] as? String) ?? ""
        let id   = (params["id"] as? String) ?? ""
        let targetId = (params["targetId"] as? String) ?? ""
        
        let success = await sw_http_upload(url: url, filePath: path, timeout: 60)
        SwWorkflowContext.shared.set(success, for: "last_upload_status")
        
        if !id.isEmpty {
            let notifyId = targetId.isEmpty ? id : targetId
            let update: [String: Any] = [notifyId: [id: success]]
            if let data = try? JSONSerialization.data(withJSONObject: update),
               let jsonStr = String(data: data, encoding: .utf8) {
                Harbour.call("SW_PIPELINE_SYNC", jsonStr)
            }
        }
        return success
    }

    @discardableResult
    static func canResume(_ params: [String: Any]) async -> Bool {
        let url = (params["url"] as? String) ?? ""
        let id  = (params["id"] as? String) ?? ""
        let targetId = (params["targetId"] as? String) ?? ""
        
        let result = await sw_http_can_resume(url: url)
        SwWorkflowContext.shared.set(result, for: "last_can_resume")
        
        if !id.isEmpty {
            let notifyId = targetId.isEmpty ? id : targetId
            let update: [String: Any] = [notifyId: [id: result]]
            if let data = try? JSONSerialization.data(withJSONObject: update),
               let json = String(data: data, encoding: .utf8) {
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        }
        return result
    }

    @discardableResult
    static func getIP(_ params: [String: Any]) async -> String {
        let id = (params["id"] as? String) ?? ""
        let targetId = (params["targetId"] as? String) ?? ""
        let ip = sw_getIP()
        print("🏝️ [Networks] sw_getIP() produjo: '\(ip)'")
        
        SwWorkflowContext.shared.set(ip, for: "local_ip")
        
        if !id.isEmpty {
            let notifyId = targetId.isEmpty ? id : targetId
            let update: [String: Any] = [notifyId: [id: ip]]
            if let data = try? JSONSerialization.data(withJSONObject: update),
               let json = String(data: data, encoding: .utf8) {
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        }
        return ip
    }

    @discardableResult
    static func isConnected(_ params: [String: Any]) async -> Bool {
        let id = (params["id"] as? String) ?? ""
        let targetId = (params["targetId"] as? String) ?? ""
        let status = sw_isConnected()
        
        SwWorkflowContext.shared.set(status, for: "is_connected")
        
        if !id.isEmpty {
            let notifyId = targetId.isEmpty ? id : targetId
            let update: [String: Any] = [notifyId: [id: status]]
            if let data = try? JSONSerialization.data(withJSONObject: update),
               let json = String(data: data, encoding: .utf8) {
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        }
        return status
    }

    static func setHeader(_ params: [String: Any]) {
        let key = (params["key"] as? String) ?? ""
        let val = (params["value"] as? String) ?? ""
        sw_http_set_header(key: key, value: val)
    }

    static func clearHeaders(_ params: [String: Any]) {
        sw_http_clear_headers()
    }
}
