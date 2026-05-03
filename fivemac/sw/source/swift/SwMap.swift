import SwiftUI
import MapKit

// MARK: - Estructura de Datos
public struct SwAnnotation: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var lat: Double
    public var lon: Double
    public var title: String
    public var subtitle: String?
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    public init(lat: Double, lon: Double, title: String, subtitle: String? = nil) {
        self.lat = lat
        self.lon = lon
        self.title = title
        self.subtitle = subtitle
    }
}

struct MapInit: Codable, GeometryProtocol {
    var lat: Double?; var lon: Double?
    var zoom: Double?; var type: Int?
    var width: Double?; var height: Double?; var top: Double?; var left: Double?
    var resizemask: Int?; var parentwidth: Double?; var parentheight: Double?
}

// MARK: - Estado y Lógica
@Observable
public class SwiftMapState: SwApplyable {
    public var position: MapCameraPosition = .automatic
    public var center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.4167, longitude: -3.7037)
    public var distance: Double = 10000
    public var pitch: Double = 0
    public var heading: Double = 0
    
    public var mapStyle: Int = 0 
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var showsTraffic: Bool = false
    public var annotations: [SwAnnotation] = []
    
    public init() {}

    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "lat":
            if let n = SwUtils.toDouble(value) { self.center.latitude = n; updateCamera() }
        case "lon":
            if let n = SwUtils.toDouble(value) { self.center.longitude = n; updateCamera() }
        case "zoom", "distance":
            if let n = SwUtils.toDouble(value) { 
                self.distance = n < 10 ? n * 100000 : n 
                updateCamera() 
            }
        case "pitch":
            if let n = SwUtils.toDouble(value) { self.pitch = n; updateCamera() }
        case "heading":
            if let n = SwUtils.toDouble(value) { self.heading = n; updateCamera() }
        case "style":
            if let n = SwUtils.toInt(value) { self.mapStyle = n }
        case "traffic":
            self.showsTraffic = SwUtils.toBool(value)
        case "search":
            if let text = value as? String { searchLocation(text) }
        case "addannotation":
            if let dict = value as? [String: Any],
               let lat = SwUtils.toDouble(dict["lat"] as Any),
               let lon = SwUtils.toDouble(dict["lon"] as Any) {
                let anno = SwAnnotation(lat: lat, lon: lon, 
                                      title: dict["title"] as? String ?? "", 
                                      subtitle: dict["subtitle"] as? String)
                self.annotations.append(anno)
            }
        case "removeannotations":
            self.annotations.removeAll()
        case "camera":
            if let dict = value as? [String: Any] {
                if let n = SwUtils.toDouble(dict["pitch"] as Any)    { self.pitch = n }
                if let n = SwUtils.toDouble(dict["heading"] as Any)  { self.heading = n }
                if let n = SwUtils.toDouble(dict["distance"] as Any) { self.distance = n }
                updateCamera()
            }
        default: break
        }
    }
    
    private func searchLocation(_ text: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, let item = response.mapItems.first else { return }
            DispatchQueue.main.async {
                self.center = item.location.coordinate
                self.distance = 5000
                self.updateCamera()
            }
        }
    }
    
    public func updateCamera() {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.position = .camera(MapCamera(centerCoordinate: center, distance: distance, heading: heading, pitch: pitch))
        }
    }
    
    public func syncFromCamera(_ camera: MapCamera) {
        self.center = camera.centerCoordinate
        self.distance = camera.distance
        self.pitch = camera.pitch
        self.heading = camera.heading
    }
}

// MARK: - Vista Principal
public struct SwiftMapView: View {
    @Bindable var state: SwiftMapState
    
    public var body: some View {
        if state.isVisible {
            Map(position: $state.position) {
                ForEach(state.annotations) { anno in
                    Marker(anno.title, coordinate: anno.coordinate)
                }
            }
            .onMapCameraChange { context in
                state.syncFromCamera(context.camera)
            }
            .mapStyle(currentStyle)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
            .opacity(state.isEnabled ? 1.0 : 0.5)
        }
    }
    
    private var currentStyle: MapStyle {
        switch state.mapStyle {
        case 1: return .imagery(elevation: .realistic) 
        case 2: return .hybrid(elevation: .realistic, showsTraffic: state.showsTraffic)
        default: return .standard(elevation: .realistic, showsTraffic: state.showsTraffic)
        }
    }
}

// MARK: - Factory
extension SwiftMapView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(MapInit.self, from: jsonData)
        let state = SwiftMapState()
        if let lat = initial.lat { state.center.latitude = lat }
        if let lon = initial.lon { state.center.longitude = lon }
        if let zoom = initial.zoom { state.distance = zoom < 10 ? zoom * 100000 : zoom }
        if let type = initial.type { state.mapStyle = type }
        
        state.updateCamera()
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .map, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}
