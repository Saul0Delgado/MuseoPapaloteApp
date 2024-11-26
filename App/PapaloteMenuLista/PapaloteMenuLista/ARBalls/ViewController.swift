import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    private var sceneView: ARSCNView!
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        startCubeGeneration()
    }
    
    private func setupAR() {
        // Create AR Scene View
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        
        // Set up scene
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        
        // Enable default lighting
        sceneView.autoenablesDefaultLighting = true
        
        // Configure AR World Tracking
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Add physics to the scene
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
    }
    
    private func startCubeGeneration() {
        // Generate a new cube every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.createFallingCube()
        }
    }
    
    private func createFallingCube() {
        // Create cube geometry
        let cubeSize: CGFloat = 0.1 // 10cm cube
        let cube = SCNBox(width: cubeSize, height: cubeSize, length: cubeSize, chamferRadius: 0)
        
        // Random color for each cube
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .purple, .orange]
        cube.firstMaterial?.diffuse.contents = colors.randomElement()
        
        // Create node with physics body
        let cubeNode = SCNNode(geometry: cube)
        
        // Add physics body
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = 1.0
        physicsBody.restitution = 0.5 // Bounce factor
        physicsBody.friction = 0.5
        cubeNode.physicsBody = physicsBody
        
        // Random position above the camera
        guard let frame = sceneView.session.currentFrame else { return }
        let camera = frame.camera
        
        // Position cube 2 meters above camera, with random X and Z offsets
        let randomX = Float.random(in: -1...1)
        let randomZ = Float.random(in: -1...1)
        let cameraTransform = camera.transform
        let translation = matrix_identity_float4x4.translated(x: randomX, y: 2.0, z: randomZ)
        let transformMatrix = matrix_multiply(cameraTransform, translation)
        
        cubeNode.simdTransform = transformMatrix
        
        // Add to scene
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        // Create invisible plane for physics collision
        let plane = SCNPlane(width: 2, height: 2)
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2 // Rotate to horizontal
        
        // Add physics body to plane
        let physicsShape = SCNPhysicsShape(geometry: plane, options: nil)
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        planeNode.physicsBody = physicsBody
        
        node.addChildNode(planeNode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        sceneView.session.pause()
    }
}

// Helper extension for matrix transformation
extension matrix_float4x4 {
    func translated(x: Float, y: Float, z: Float) -> matrix_float4x4 {
        var matrix = self
        matrix.columns.3.x += x
        matrix.columns.3.y += y
        matrix.columns.3.z += z
        return matrix
    }
}
