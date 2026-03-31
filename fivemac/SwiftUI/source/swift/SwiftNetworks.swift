import SwiftUI
import Foundation
import Network
#if canImport(Darwin)
import Darwin
#endif

import HarbourMacro

// Almacén estático para las cabeceras personalizadas
private var customHeaders: [String: String] = [:]

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_set_header(key: String, value: String) {
    if value.isEmpty {
        customHeaders.removeValue(forKey: key)
    } else {
        customHeaders[key] = value
    }
}

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_clear_headers() {
    customHeaders.removeAll()
}

//----------------------------------------------------------------------------//

@HarbourDirect
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

@HarbourDirect
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

@HarbourDirect
public func sw_http_get_json(url: String) -> Any? {
    guard let urlObj = URL(string: url) else { return "Error: Invalid URL" }

    let semaphore = DispatchSemaphore(value: 0)
    var data: Data?

    var request = URLRequest(url: urlObj)
    request.httpMethod = "GET"
    
    // Aplicamos User-Agent por defecto
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36", forHTTPHeaderField: "User-Agent")

    // Aplicamos Cabeceras personalizadas
    for (key, value) in customHeaders {
        request.setValue(value, forHTTPHeaderField: key)
    }

    URLSession.shared.dataTask(with: request) { d, _, _ in
        data = d
        semaphore.signal()
    }.resume()

    _ = semaphore.wait(timeout: .now() + 30.0)

    if let jsonData = data {
        do {
            return try JSONSerialization.jsonObject(with: jsonData, options: [])
        } catch {
            return "JSON Error: \(error.localizedDescription)"
        }
    }
    return "Network Error: No response"
}

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_get(url: String, timeout: Double) -> String {
    return sw_perform_request(url: url, method: "GET", body: nil, timeout: timeout)
}

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_post(url: String, json: String, timeout: Double) -> String {
    return sw_perform_request(url: url, method: "POST", body: json, timeout: timeout)
}

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_put(url: String, json: String, timeout: Double) -> String {
    return sw_perform_request(url: url, method: "PUT", body: json, timeout: timeout)
}

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_delete(url: String, timeout: Double) -> String {
    return sw_perform_request(url: url, method: "DELETE", body: nil, timeout: timeout)
}

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_download(url: String, destination: String) -> Bool {
    guard let urlObj = URL(string: url) else { return false }
    let destURL = URL(fileURLWithPath: destination)
    
    let semaphore = DispatchSemaphore(value: 0)
    var success = false
    
    var request = URLRequest(url: urlObj)
    for (key, value) in customHeaders {
        request.setValue(value, forHTTPHeaderField: key)
    }
    
    URLSession.shared.downloadTask(with: request) { tempURL, response, error in
        if let temp = tempURL {
            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.moveItem(at: temp, to: destURL)
                success = true
            } catch {
                print("Download Move Error: \(error)")
            }
        }
        semaphore.signal()
    }.resume()
    
    _ = semaphore.wait(timeout: .now() + 60.0)
    return success
}

//----------------------------------------------------------------------------//
// FUNCION AUXILIAR UNIFICADA PARA PETICIONES SÍNCRONAS
//----------------------------------------------------------------------------//

private func sw_perform_request(url: String, method: String, body: String?, timeout: Double) -> String {
    guard let urlObj = URL(string: url) else { return "" }
    
    let realTimeout = timeout > 0 ? timeout : 30.0
    let semaphore = DispatchSemaphore(value: 0)
    var result = ""
    
    var request = URLRequest(url: urlObj)
    request.httpMethod = method
    request.timeoutInterval = realTimeout
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36", forHTTPHeaderField: "User-Agent")
    
    // Aplicamos Cabeceras personalizadas
    for (key, value) in customHeaders {
        request.setValue(value, forHTTPHeaderField: key)
    }

    if let b = body {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = b.data(using: .utf8)
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, _, _ in
        if let d = data, let content = String(data: d, encoding: .utf8) {
            result = content
        }
        semaphore.signal()
    }
    task.resume()
    
    _ = semaphore.wait(timeout: .now() + realTimeout)
    return result
}

//----------------------------------------------------------------------------//

@HarbourDirect
public func sw_http_upload(url: String, filePath: String) -> Bool {
    guard let urlObj = URL(string: url) else { return false }
    let fileURL = URL(fileURLWithPath: filePath)
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else { return false }
    
    let semaphore = DispatchSemaphore(value: 0)
    var success = false
    
    var request = URLRequest(url: urlObj)
    request.httpMethod = "POST"
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    
    // Aplicamos User-Agent por defecto
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36", forHTTPHeaderField: "User-Agent")

    // Aplicamos Cabeceras personalizadas
    for (key, value) in customHeaders {
        request.setValue(value, forHTTPHeaderField: key)
    }

    URLSession.shared.uploadTask(with: request, fromFile: fileURL) { _, _, error in
        if error == nil {
            success = true
        }
        semaphore.signal()
    }.resume()
    
    _ = semaphore.wait(timeout: .now() + 60.0)
    return success
}
