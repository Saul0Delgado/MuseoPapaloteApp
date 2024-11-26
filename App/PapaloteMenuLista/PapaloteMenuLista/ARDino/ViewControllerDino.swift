import UIKit
import ARKit

class ViewControllerDino: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var skullNode: SCNNode!
    var overlayNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the ARSCNView
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        self.view.addSubview(sceneView)

        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene

        // Load the skull model
        loadSkullModel()

        // Create the overlay
        createOverlay()

        // Set up touch handling
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)

        // Run the session
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    func loadSkullModel() {
        guard let skullScene = SCNScene(named: "trex_skull.usdz") else {
            print("Failed to load trex_skull.usdz")
            return
        }

        skullNode = skullScene.rootNode.clone()

        // Adjust the scale to reduce the size (e.g., 10% of original size)
        skullNode.scale = SCNVector3(0.1, 0.1, 0.1)

        // Adjust the position to place it 1 meter in front of the camera
        skullNode.position = SCNVector3(0, -0.1, -1.0)

        // Directly access sceneView.scene without unwrapping
        sceneView.scene.rootNode.addChildNode(skullNode)
    }

    func createOverlay() {
        // Get the bounding box of the skull node
        let (minVec, maxVec) = skullNode.boundingBox

        // Adjust for scaling
        let width = CGFloat(maxVec.x - minVec.x) * CGFloat(skullNode.scale.x)
        let height = CGFloat(maxVec.y - minVec.y) * CGFloat(skullNode.scale.y)

        let planeGeometry = SCNPlane(width: width, height: height)

        // Create an SKScene for transparency content
        let skSceneSize = CGSize(width: 2048, height: 2048)
        let skScene = SKScene(size: skSceneSize)
        skScene.backgroundColor = .black

        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor(red: 237/255, green: 201/255, blue: 175/255, alpha: 1.0) // Sand color
        maskMaterial.transparencyMode = .aOne
        maskMaterial.transparent.contents = skScene
        maskMaterial.isDoubleSided = true
        maskMaterial.writesToDepthBuffer = false

        planeGeometry.materials = [maskMaterial]

        overlayNode = SCNNode(geometry: planeGeometry)
        overlayNode.position = SCNVector3(0, 0, 0.01) // Slightly in front of skull
        overlayNode.eulerAngles = SCNVector3Zero // Face the camera

        skullNode.addChildNode(overlayNode)
        print("Overlay node added to skull node")
    }

    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: sceneView)

        let hitResults = sceneView.hitTest(location, options: [SCNHitTestOption.rootNode: skullNode])
        if let hit = hitResults.first(where: { $0.node == overlayNode }) {
            print("Overlay node touched")

            // Proceed with revealing the skull
            let texcoord = hit.textureCoordinates(withMappingChannel: 0)
            let skSceneSize = CGSize(width: 2048, height: 2048)
            let x = texcoord.x * skSceneSize.width
            let y = (1 - texcoord.y) * skSceneSize.height // Invert y-axis

            if let material = overlayNode.geometry?.firstMaterial,
               let skScene = material.transparent.contents as? SKScene {
                let brushSize: CGFloat = 50.0
                let brushNode = SKShapeNode(circleOfRadius: brushSize / 2)
                brushNode.position = CGPoint(x: x, y: y)
                brushNode.fillColor = .white
                brushNode.strokeColor = .clear
                brushNode.blendMode = .alpha
                skScene.addChild(brushNode)
            }
        } else {
            print("No overlay node touched")
        }
    }
}
