import Foundation

/// PUENTE DEFINITIVO HARBOUR-SWIFT (HSW)
/// Todas estas funciones son visibles directamente desde Harbour (.prg)

/// SW_HB_SEND_SW( cJson )
/// Envía un comando JSON a Swift de forma asíncrona
@_cdecl("HB_FUN_SW_HB_SEND_SW")
public func sw_hb_send_sw_hb(_ p: UnsafeMutableRawPointer?) {
    guard let jsonStr = hb_parc(1).map({ String(cString: $0) }) else { return }
    Task {
        await SwDispatcher.shared.executeAsyncInternal(json: jsonStr)
    }
}

/// SW_GET_PROXY_MAP() -> cJsonMap
/// Retorna el mapa de proxies registrados en la Isla
@_cdecl("HB_FUN_SW_GET_PROXY_MAP")
public func sw_get_proxy_map_hb(_ p: UnsafeMutableRawPointer?) {
    _ = SwDispatcher.shared
    let map = SwCapabilities.shared.getProxyMap()
    if let data = try? JSONSerialization.data(withJSONObject: map),
       let jsonStr = String(data: data, encoding: .utf8) {
        Harbour.ret(jsonStr)
    } else {
        Harbour.ret("{}")
    }
}


/// SW_HB_SEND_SYNC( cJson ) -> cResultJson
/// Ejecuta un comando y espera el resultado (Síncrono)
@_cdecl("HB_FUN_SW_HB_SEND_SYNC")
public func sw_hb_send_sync_hb(_ p: UnsafeMutableRawPointer?) {
    let json = hb_parc(1).map { String(cString: $0) } ?? "[]"
    
    let semaphore = DispatchSemaphore(value: 0)
    var result = "{}"
    Task {
        result = await SwDispatcher.shared.executeSyncInternal(json: json)
        semaphore.signal()
    }
    _ = semaphore.wait(timeout: .distantFuture)
    Harbour.ret(result)
}

/// SW_HB_QUERY_SW( cJson ) -> cResultJson
/// Realiza una consulta de datos y espera respuesta
@_cdecl("HB_FUN_SW_HB_QUERY_SW")
public func sw_hb_query_sw_hb(_ p: UnsafeMutableRawPointer?) {
    sw_hb_send_sync_hb(p)
}

/// SW_GET_EVENTS() -> cJsonEvents
/// Harbour llama a esto en cada SysRefresh para recoger la cola de eventos
@_cdecl("HB_FUN_SW_GET_EVENTS")
public func sw_get_events_hb(_ p: UnsafeMutableRawPointer?) {
    let events = SwDispatcher.shared.flushEvents()
    if let data = try? JSONSerialization.data(withJSONObject: events),
       let json = String(data: data, encoding: .utf8) {
        Harbour.ret(json)
    } else {
        Harbour.ret("[]")
    }
}
