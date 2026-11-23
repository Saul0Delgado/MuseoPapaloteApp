//
//  MapaSceneView.swift
//  PapaloteMenuLista
//
//  Mapa 3D: extruye las zonas del SVG con SceneKit y coloca encima
//  los modelos .dae de las exhibiciones de cada zona.

import SwiftUI
import SceneKit

// MARK: - Datos de cada zona

struct MapaZonaInfo {
    let color: UIColor
    let modelos: [String]
}

// MARK: - Parser de SVG (solo los comandos que usan los mapas del museo)

struct MapaSVGShape {
    let id: String
    let path: UIBezierPath   // en coordenadas del SVG (y hacia abajo)
}

enum MapaSVGParser {
    static func parse(svgName: String) -> (viewBox: CGSize, shapes: [MapaSVGShape]) {
        guard let url = Bundle.main.url(forResource: svgName, withExtension: "svg"),
              let parser = XMLParser(contentsOf: url) else {
            print("⚠️ No se encontró el SVG: \(svgName)")
            return (CGSize(width: 1063, height: 1063), [])
        }
        let delegate = Delegate()
        parser.delegate = delegate
        parser.parse()
        return (delegate.viewBox, delegate.shapes)
    }

    private final class Delegate: NSObject, XMLParserDelegate {
        var viewBox = CGSize(width: 1063, height: 1063)
        var shapes: [MapaSVGShape] = []

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
            if elementName == "svg", let box = attributeDict["viewBox"] {
                let v = box.split(whereSeparator: { $0 == " " || $0 == "," }).compactMap { Double($0) }
                if v.count == 4 { viewBox = CGSize(width: v[2], height: v[3]) }
            } else if elementName == "path", let d = attributeDict["d"] {
                let id = attributeDict["id"] ?? attributeDict["name"] ?? UUID().uuidString
                shapes.append(MapaSVGShape(id: id, path: MapaSVGParser.bezierPath(from: d)))
            }
        }
    }

    // Convierte el atributo `d` en un UIBezierPath. Soporta M L H V C S Q T Z (absolutos y relativos).
    static func bezierPath(from d: String) -> UIBezierPath {
        let path = UIBezierPath()
        var tokens: [String] = []
        var number = ""

        func flushNumber() {
            if !number.isEmpty { tokens.append(number); number = "" }
        }
        for ch in d {
            if ch.isLetter && ch != "e" && ch != "E" {
                flushNumber()
                tokens.append(String(ch))
            } else if ch == " " || ch == "," || ch == "\n" || ch == "\t" {
                flushNumber()
            } else if ch == "-" {
                // Un "-" inicia un número nuevo, salvo que siga a un exponente
                if let last = number.last, last == "e" || last == "E" {
                    number.append(ch)
                } else {
                    flushNumber()
                    number.append(ch)
                }
            } else if ch == "." && number.contains(".") {
                // "1.5.5" == "1.5" y ".5"
                flushNumber()
                number.append(ch)
            } else {
                number.append(ch)
            }
        }
        flushNumber()

        var i = 0
        var cmd: Character = "M"
        var current = CGPoint.zero
        var start = CGPoint.zero
        var lastControl = CGPoint.zero
        var lastCmd: Character = "M"

        func next() -> CGFloat? {
            guard i < tokens.count, let v = Double(tokens[i]) else { return nil }
            i += 1
            return CGFloat(v)
        }

        while i < tokens.count {
            if let first = tokens[i].first, first.isLetter {
                cmd = first
                i += 1
                if cmd == "z" || cmd == "Z" {
                    path.close()
                    current = start
                    lastCmd = cmd
                    continue
                }
            }
            let rel = cmd.isLowercase
            let ox = rel ? current.x : 0
            let oy = rel ? current.y : 0

            switch cmd.uppercased() {
            case "M":
                guard let x = next(), let y = next() else { i = tokens.count; break }
                current = CGPoint(x: x + ox, y: y + oy)
                start = current
                path.move(to: current)
                cmd = rel ? "l" : "L"  // pares siguientes son lineas
            case "L":
                guard let x = next(), let y = next() else { i = tokens.count; break }
                current = CGPoint(x: x + ox, y: y + oy)
                path.addLine(to: current)
            case "H":
                guard let x = next() else { i = tokens.count; break }
                current = CGPoint(x: x + ox, y: current.y)
                path.addLine(to: current)
            case "V":
                guard let y = next() else { i = tokens.count; break }
                current = CGPoint(x: current.x, y: y + oy)
                path.addLine(to: current)
            case "C":
                guard let x1 = next(), let y1 = next(), let x2 = next(), let y2 = next(),
                      let x = next(), let y = next() else { i = tokens.count; break }
                let c1 = CGPoint(x: x1 + ox, y: y1 + oy)
                let c2 = CGPoint(x: x2 + ox, y: y2 + oy)
                current = CGPoint(x: x + ox, y: y + oy)
                path.addCurve(to: current, controlPoint1: c1, controlPoint2: c2)
                lastControl = c2
            case "S":
                guard let x2 = next(), let y2 = next(), let x = next(), let y = next() else { i = tokens.count; break }
                let c1 = "CS".contains(lastCmd.uppercased())
                    ? CGPoint(x: 2 * current.x - lastControl.x, y: 2 * current.y - lastControl.y)
                    : current
                let c2 = CGPoint(x: x2 + ox, y: y2 + oy)
                current = CGPoint(x: x + ox, y: y + oy)
                path.addCurve(to: current, controlPoint1: c1, controlPoint2: c2)
                lastControl = c2
            case "Q":
                guard let x1 = next(), let y1 = next(), let x = next(), let y = next() else { i = tokens.count; break }
                let c = CGPoint(x: x1 + ox, y: y1 + oy)
                current = CGPoint(x: x + ox, y: y + oy)
                path.addQuadCurve(to: current, controlPoint: c)
                lastControl = c
            case "T":
                guard let x = next(), let y = next() else { i = tokens.count; break }
                let c = "QT".contains(lastCmd.uppercased())
                    ? CGPoint(x: 2 * current.x - lastControl.x, y: 2 * current.y - lastControl.y)
                    : current
                current = CGPoint(x: x + ox, y: y + oy)
                path.addQuadCurve(to: current, controlPoint: c)
                lastControl = c
            default:
                // Comando no soportado (p. ej. arcos): se detiene el parseo de este path
                print("⚠️ Comando SVG no soportado: \(cmd)")
                i = tokens.count
            }
            lastCmd = cmd
        }
        return path
    }
}

// MARK: - Vista SceneKit

struct MapaSceneView: UIViewRepresentable {
    let svgName: String
    let zonas: [String: MapaZonaInfo]
    let colorPorDefecto: (String) -> UIColor
    let onSelectZona: (String) -> Void

    private static let extrusion: CGFloat = 6

    /// Giro horizontal (en grados) por modelo, para corregir hacia donde "mira" cada uno. Ej: "Radio": 90
    private static let giroPorModelo: [String: Float] = [:]
    private static let zonaPrefix = "zona:"

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = SCNScene()
        view.backgroundColor = .white
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        // Control de camara propio: solo gira alrededor del eje vertical (sin ver por debajo del mapa) y hace zoom
        view.allowsCameraControl = false

        let camera = SCNCamera()
        camera.zFar = 5000
        camera.projectionDirection = .horizontal  // el mapa es cuadrado y la pantalla vertical: se ajusta al ancho
        camera.fieldOfView = 45
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        let center = SCNNode()
        view.scene?.rootNode.addChildNode(center)
        let look = SCNLookAtConstraint(target: center)
        look.isGimbalLockEnabled = true
        cameraNode.constraints = [look]
        view.scene?.rootNode.addChildNode(cameraNode)
        view.pointOfView = cameraNode

        let coordinator = context.coordinator
        coordinator.cameraNode = cameraNode
        coordinator.updateCamera()

        let tap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleTap(_:)))
        let pan = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePan(_:)))
        let pinch = UIPinchGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePinch(_:)))
        [tap, pan, pinch].forEach { view.addGestureRecognizer($0) }
        context.coordinator.view = view
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.onSelect = onSelectZona

        // Solo se reconstruye cuando cambia el piso o los datos de las zonas
        let signature = svgName + "|" + zonas.keys.sorted().map { key in
            "\(key):\(zonas[key]?.modelos.joined(separator: ",") ?? "")"
        }.joined(separator: ";")
        guard context.coordinator.signature != signature else { return }
        context.coordinator.signature = signature

        view.scene?.rootNode.childNode(withName: "mapa", recursively: false)?.removeFromParentNode()
        let mapa = buildMap()
        mapa.name = "mapa"
        view.scene?.rootNode.addChildNode(mapa)
    }

    // MARK: Construccion del mapa

    private func buildMap() -> SCNNode {
        let root = SCNNode()
        let parsed = MapaSVGParser.parse(svgName: svgName)
        let cx = parsed.viewBox.width / 2
        let cy = parsed.viewBox.height / 2

        for shape in parsed.shapes {
            let esFondo = shape.id.hasPrefix("Fondo") || shape.id == "path2"

            // Se centra el path y se invierte Y para que, al acostar el nodo, quede igual que el SVG
            let local = shape.path.copy() as! UIBezierPath
            local.apply(CGAffineTransform(translationX: -cx, y: -cy))
            local.apply(CGAffineTransform(scaleX: 1, y: -1))

            let depth: CGFloat = esFondo ? 2 : Self.extrusion
            local.flatness = 0.5
            let geometry = SCNShape(path: local, extrusionDepth: depth)

            let material = SCNMaterial()
            material.diffuse.contents = esFondo ? UIColor(white: 0.85, alpha: 1) : (zonas[shape.id]?.color ?? colorPorDefecto(shape.id))
            material.isDoubleSided = true
            geometry.materials = [material]

            let node = SCNNode(geometry: geometry)
            node.eulerAngles.x = -.pi / 2
            node.position.y = Float(esFondo ? -2 : depth / 2)
            node.name = esFondo ? "fondo" : Self.zonaPrefix + shape.id
            root.addChildNode(node)

            // Modelos de las exhibiciones sobre la zona
            if !esFondo, let info = zonas[shape.id], !info.modelos.isEmpty {
                let centroid = Self.centroid(of: shape.path)
                let base = SCNVector3(Float(centroid.x - cx), Float(depth), Float(centroid.y - cy))
                root.addChildNode(modelosNode(info.modelos, at: base, zonaID: shape.id))
            }
        }
        return root
    }

    private func modelosNode(_ modelos: [String], at base: SCNVector3, zonaID: String) -> SCNNode {
        let group = SCNNode()
        group.position = base
        let radius: Float = modelos.count > 1 ? 45 : 0
        for (index, name) in modelos.enumerated() {
            guard let model = Self.loadModel(named: name) else { continue }
            let angle = Float(index) / Float(modelos.count) * 2 * .pi
            model.position.x += radius * cos(angle)
            model.position.z += radius * sin(angle)
            // Los toques sobre un modelo cuentan como toques a su zona
            model.name = Self.zonaPrefix + zonaID
            group.addChildNode(model)
        }
        return group
    }

    /// Carga el .dae, quita luces/camaras, lo escala a un tamano fijo y apoya su base en y = 0.
    private static func loadModel(named name: String) -> SCNNode? {
        guard let scene = SCNScene(named: "\(name).dae") else {
            print("⚠️ No se pudo cargar el modelo: \(name).dae")
            return nil
        }
        let content = scene.rootNode.clone()
        content.enumerateHierarchy { child, _ in
            if child.light != nil || child.camera != nil {
                child.light = nil
                child.camera = nil
            }
        }

        // Los .dae de Blender son Z-up y SceneKit no los convierte: se gira -90° en X para que queden de pie
        let node = SCNNode()
        content.eulerAngles.x = -.pi / 2
        node.addChildNode(content)

        let (minB, maxB) = node.boundingBox
        let size = SCNVector3(maxB.x - minB.x, maxB.y - minB.y, maxB.z - minB.z)
        let largest = max(size.x, size.y, size.z)
        guard largest > 0 else { return nil }
        let scale = 55 / largest

        let wrapper = SCNNode()
        node.scale = SCNVector3(scale, scale, scale)
        // Centrado en x/z y base en y = 0
        node.position = SCNVector3(-(minB.x + maxB.x) / 2 * scale,
                                   -minB.y * scale,
                                   -(minB.z + maxB.z) / 2 * scale)
        wrapper.addChildNode(node)
        wrapper.eulerAngles.y = (giroPorModelo[name] ?? 0) * .pi / 180
        return wrapper
    }

    /// Centroide (por area) del primer subpath aplanado; si falla, el centro de su bounding box.
    private static func centroid(of path: UIBezierPath) -> CGPoint {
        var points: [CGPoint] = []
        var current = CGPoint.zero
        path.cgPath.applyWithBlock { pointer in
            let e = pointer.pointee
            let p = e.points
            switch e.type {
            case .moveToPoint:
                if !points.isEmpty { return }
                current = p[0]; points.append(current)
            case .addLineToPoint:
                current = p[0]; points.append(current)
            case .addQuadCurveToPoint:
                let c = p[0], end = p[1]
                for s in 1...8 {
                    let t = CGFloat(s) / 8, u = 1 - t
                    points.append(CGPoint(x: u * u * current.x + 2 * u * t * c.x + t * t * end.x,
                                          y: u * u * current.y + 2 * u * t * c.y + t * t * end.y))
                }
                current = end
            case .addCurveToPoint:
                let c1 = p[0], c2 = p[1], end = p[2]
                for s in 1...8 {
                    let t = CGFloat(s) / 8, u = 1 - t
                    points.append(CGPoint(x: u * u * u * current.x + 3 * u * u * t * c1.x + 3 * u * t * t * c2.x + t * t * t * end.x,
                                          y: u * u * u * current.y + 3 * u * u * t * c1.y + 3 * u * t * t * c2.y + t * t * t * end.y))
                }
                current = end
            default:
                break
            }
        }

        var area: CGFloat = 0, cx: CGFloat = 0, cy: CGFloat = 0
        for k in 0..<points.count {
            let a = points[k], b = points[(k + 1) % points.count]
            let cross = a.x * b.y - b.x * a.y
            area += cross
            cx += (a.x + b.x) * cross
            cy += (a.y + b.y) * cross
        }
        if abs(area) > 1e-6 {
            return CGPoint(x: cx / (3 * area), y: cy / (3 * area))
        }
        let box = path.bounds
        return CGPoint(x: box.midX, y: box.midY)
    }

    // MARK: Coordinator (toques)

    final class Coordinator: NSObject {
        weak var view: SCNView?
        var cameraNode: SCNNode?
        private var yaw: Float = 0
        private let pitch: Float = 0.9          // inclinacion fija (rad) sobre el plano del mapa
        private var distance: Float = 1300
        private var distanceAtPinchStart: Float = 1300
        var onSelect: (String) -> Void = { _ in }
        var signature = ""

        func updateCamera() {
            let horizontal = distance * cos(pitch)
            cameraNode?.position = SCNVector3(horizontal * sin(yaw), distance * sin(pitch), horizontal * cos(yaw))
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            // Solo el movimiento horizontal gira el mapa
            yaw -= Float(gesture.translation(in: gesture.view).x) * 0.008
            gesture.setTranslation(.zero, in: gesture.view)
            updateCamera()
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            if gesture.state == .began { distanceAtPinchStart = distance }
            distance = min(max(distanceAtPinchStart / Float(gesture.scale), 400), 2200)
            updateCamera()
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view else { return }
            let hits = view.hitTest(gesture.location(in: view), options: nil)
            for hit in hits {
                var node: SCNNode? = hit.node
                while let n = node {
                    if let name = n.name, name.hasPrefix(MapaSceneView.zonaPrefix) {
                        onSelect(String(name.dropFirst(MapaSceneView.zonaPrefix.count)))
                        return
                    }
                    node = n.parent
                }
            }
        }
    }
}
