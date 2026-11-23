import SwiftUI
import SceneKit

struct SceneModelView: UIViewRepresentable {
    let modelName: String  // Nombre del modelo
    let color: Color       // Color del modelo según la zona

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.white
        
        let cameraNode  = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0,0,20)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        sceneView.defaultCameraController.maximumVerticalAngle = 0
        sceneView.defaultCameraController.minimumVerticalAngle = 0
        sceneView.defaultCameraController.maximumHorizontalAngle = 360

        // Intentar cargar el modelo 3D correspondiente
        if let objectNode = loadModel(named: modelName) {
            sceneView.scene?.rootNode.addChildNode(objectNode)
        } else {
            print("⚠️ No se encontró el modelo: \(modelName)")
        }

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
          // Reinicia la escena con un nuevo modelo si el nombre cambia
          // Solo se reemplaza el modelo (la camara debe quedarse en la escena)
          uiView.scene?.rootNode.childNode(withName: "modelo", recursively: false)?.removeFromParentNode()
          if let objectNode = loadModel(named: modelName) {
              uiView.scene?.rootNode.addChildNode(objectNode)
          }
      }

    // Cargar el modelo 3D con nombre específico
    func loadModel(named name: String) -> SCNNode? {
        guard let scene = SCNScene(named: "\(name).dae") else {
            print("⚠️ No se pudo cargar la escena para: \(name).dae")
            return nil
        }

        let content = scene.rootNode.clone()
        content.enumerateHierarchy { child, _ in
            child.light = nil
            child.camera = nil
        }

        // Los .dae de Blender son Z-up y SceneKit no los convierte: se gira -90° en X para que queden de pie
        let holder = SCNNode()
        content.eulerAngles.x = -.pi / 2
        holder.addChildNode(content)

        // Se escala para que quepa en el encuadre y se centra en el origen
        let (minB, maxB) = holder.boundingBox
        let largest = max(maxB.x - minB.x, maxB.y - minB.y, maxB.z - minB.z)
        guard largest > 0 else { return nil }
        let scale = 12 / largest

        let wrapper = SCNNode()
        wrapper.name = "modelo"
        holder.scale = SCNVector3(scale, scale, scale)
        holder.position = SCNVector3(-(minB.x + maxB.x) / 2 * scale,
                                     -(minB.y + maxB.y) / 2 * scale,
                                     -(minB.z + maxB.z) / 2 * scale)
        wrapper.addChildNode(holder)
        return wrapper
    }
}

// Extensión para convertir Color de SwiftUI a UIColor
extension UIColor {
    convenience init(_ color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        self.init(
            red: components[0],
            green: components[1],
            blue: components[2],
            alpha: components[3]
        )
    }
}


// Extensión para convertir hex a Color de SwiftUI
extension Color {
    init(hexValue: String) {
        let hex = hexValue.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 0.0; g = 0.0; b = 0.0  // Valores por defecto en caso de error
        }
        self.init(red: r, green: g, blue: b)
    }
}


