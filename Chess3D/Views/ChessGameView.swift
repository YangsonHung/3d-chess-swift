import AppKit
import SceneKit
import SwiftChess

class ChessGameView: NSView {

    var gameManager: GameManager!

    private var scnView: SCNView!
    private var scene: SCNScene!
    private var cameraNode: SCNNode!
    private var boardNode: SCNNode!
    private var piecesNode: SCNNode!
    private var highlightNodes: [SCNNode] = []

    private var selectedSquare: (row: Int, col: Int)?
    private var validMoves: [(row: Int, col: Int)] = []

    private let boardSize: Float = 8.0
    private let squareSize: Float = 1.0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        scnView = SCNView(frame: bounds)
        scnView.autoresizingMask = [.width, .height]
        scnView.backgroundColor = NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        scnView.allowsCameraControl = true
        scnView.antialiasingMode = .multisampling4X
        scnView.showsStatistics = false

        addSubview(scnView)

        setupScene()
        setupCamera()
        setupLights()

        scnView.scene = scene

        // 添加点击手势
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        scnView.addGestureRecognizer(clickGesture)
    }

    @objc private func handleClick(_ gesture: NSClickGestureRecognizer) {
        let location = gesture.location(in: scnView)
        handleClickAt(location)
    }

    private func setupScene() {
        scene = SCNScene()
        scene.background.contents = NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.18, alpha: 1.0)

        // 棋盘节点
        boardNode = SCNNode()
        boardNode.name = "board"
        scene.rootNode.addChildNode(boardNode)

        // 棋子节点
        piecesNode = SCNNode()
        piecesNode.name = "pieces"
        scene.rootNode.addChildNode(piecesNode)

        createBoard()
    }

    private func createBoard() {
        let boardGeometry = SCNBox(width: CGFloat(boardSize), height: 0.2, length: CGFloat(boardSize), chamferRadius: 0.02)
        let boardMaterial = SCNMaterial()
        boardMaterial.diffuse.contents = NSColor(calibratedRed: 0.35, green: 0.25, blue: 0.15, alpha: 1.0)
        boardGeometry.materials = [boardMaterial]

        let board = SCNNode(geometry: boardGeometry)
        board.position = SCNVector3(0, -0.15, 0)
        boardNode.addChildNode(board)

        // 创建64个格子
        for row in 0..<8 {
            for col in 0..<8 {
                let isLight = (row + col) % 2 == 0
                let squareNode = createChessSquare(row: row, col: col, isLight: isLight)
                boardNode.addChildNode(squareNode)
            }
        }
    }

    private func createChessSquare(row: Int, col: Int, isLight: Bool) -> SCNNode {
        let squareGeometry = SCNPlane(width: CGFloat(squareSize * 0.95), height: CGFloat(squareSize * 0.95))

        let material = SCNMaterial()
        if isLight {
            material.diffuse.contents = NSColor(calibratedRed: 0.95, green: 0.9, blue: 0.8, alpha: 1.0)
        } else {
            material.diffuse.contents = NSColor(calibratedRed: 0.4, green: 0.35, blue: 0.3, alpha: 1.0)
        }
        material.roughness.contents = 0.8

        squareGeometry.materials = [material]

        let squareNode = SCNNode(geometry: squareGeometry)
        squareNode.eulerAngles.x = -.pi / 2
        squareNode.position = SCNVector3(
            Float(col) - boardSize / 2 + 0.5,
            0.01,
            Float(row) - boardSize / 2 + 0.5
        )
        squareNode.name = "square_\(row)_\(col)"

        return squareNode
    }

    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100

        // 初始相机位置 - 从对角线上方俯视
        let distance: Float = 14.0
        let angle: Float = .pi / 6
        cameraNode.position = SCNVector3(
            distance * cos(angle),
            distance * 0.8,
            distance * sin(angle)
        )
        cameraNode.look(at: SCNVector3(0, 0, 0))

        scene.rootNode.addChildNode(cameraNode)
    }

    private func setupLights() {
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        ambientLight.light?.color = NSColor.white
        scene.rootNode.addChildNode(ambientLight)

        // 主光源
        let mainLight = SCNNode()
        mainLight.light = SCNLight()
        mainLight.light?.type = .directional
        mainLight.light?.intensity = 800
        mainLight.light?.castsShadow = true
        mainLight.light?.shadowMode = .deferred
        mainLight.light?.shadowColor = NSColor.black.withAlphaComponent(0.5)
        mainLight.position = SCNVector3(10, 15, 10)
        mainLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(mainLight)

        // 补光
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.intensity = 300
        fillLight.position = SCNVector3(-8, 10, -8)
        fillLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(fillLight)
    }

    func setupBoard() {
        // 清除现有棋子
        for child in piecesNode.childNodes {
            child.removeFromParentNode()
        }

        clearHighlights()

        // 放置初始棋子
        let initialPositions: [(row: Int, col: Int, type: Piece.PieceType, player: Color)] = [
            // 黑方
            (0, 0, .rook, .black),
            (0, 1, .knight, .black),
            (0, 2, .bishop, .black),
            (0, 3, .queen, .black),
            (0, 4, .king, .black),
            (0, 5, .bishop, .black),
            (0, 6, .knight, .black),
            (0, 7, .rook, .black),
            // 黑方兵
            (1, 0, .pawn, .black),
            (1, 1, .pawn, .black),
            (1, 2, .pawn, .black),
            (1, 3, .pawn, .black),
            (1, 4, .pawn, .black),
            (1, 5, .pawn, .black),
            (1, 6, .pawn, .black),
            (1, 7, .pawn, .black),
            // 白方兵
            (6, 0, .pawn, .white),
            (6, 1, .pawn, .white),
            (6, 2, .pawn, .white),
            (6, 3, .pawn, .white),
            (6, 4, .pawn, .white),
            (6, 5, .pawn, .white),
            (6, 6, .pawn, .white),
            (6, 7, .pawn, .white),
            // 白方
            (7, 0, .rook, .white),
            (7, 1, .knight, .white),
            (7, 2, .bishop, .white),
            (7, 3, .queen, .white),
            (7, 4, .king, .white),
            (7, 5, .bishop, .white),
            (7, 6, .knight, .white),
            (7, 7, .rook, .white),
        ]

        for pos in initialPositions {
            let pieceNode = createPieceNode(type: pos.type, player: pos.player)
            pieceNode.position = SCNVector3(
                Float(pos.col) - boardSize / 2 + 0.5,
                0,
                Float(pos.row) - boardSize / 2 + 0.5
            )
            pieceNode.name = "piece_\(pos.row)_\(pos.col)"
            piecesNode.addChildNode(pieceNode)
        }
    }

    func updatePieces() {
        // 清除现有棋子
        for child in piecesNode.childNodes {
            child.removeFromParentNode()
        }

        clearHighlights()

        // 重新放置所有棋子
        let board = gameManager.board

        for row in 0..<8 {
            for col in 0..<8 {
                let location = BoardLocation(x: col, y: 7 - row)
                if let piece = board.getPiece(at: location) {
                    let pieceNode = createPieceNode(type: piece.type, player: piece.color)
                    pieceNode.position = SCNVector3(
                        Float(col) - boardSize / 2 + 0.5,
                        0,
                        Float(row) - boardSize / 2 + 0.5
                    )
                    pieceNode.name = "piece_\(row)_\(col)"
                    piecesNode.addChildNode(pieceNode)
                }
            }
        }
    }

    private func createPieceNode(type: Piece.PieceType, player: Color) -> SCNNode {
        let pieceNode = SCNNode()

        let isWhite = player == .white

        switch type {
        case .king:
            pieceNode.addChildNode(createKingGeometry(isWhite: isWhite))
        case .queen:
            pieceNode.addChildNode(createQueenGeometry(isWhite: isWhite))
        case .rook:
            pieceNode.addChildNode(createRookGeometry(isWhite: isWhite))
        case .bishop:
            pieceNode.addChildNode(createBishopGeometry(isWhite: isWhite))
        case .knight:
            pieceNode.addChildNode(createKnightGeometry(isWhite: isWhite))
        case .pawn:
            pieceNode.addChildNode(createPawnGeometry(isWhite: isWhite))
        }

        return pieceNode
    }

    private func createPawnGeometry(isWhite: Bool) -> SCNNode {
        let parent = SCNNode()

        // 底座
        let base = SCNCylinder(radius: 0.25, height: 0.08)
        let baseMat = SCNMaterial()
        baseMat.diffuse.contents = isWhite ? NSColor.white : NSColor.black
        base.materials = [baseMat]
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.04, 0)
        parent.addChildNode(baseNode)

        // 球体
        let sphere = SCNSphere(radius: 0.2)
        let sphereMat = SCNMaterial()
        sphereMat.diffuse.contents = isWhite ? NSColor.white : NSColor.black
        sphere.materials = [sphereMat]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0.25, 0)
        parent.addChildNode(sphereNode)

        return parent
    }

    private func createRookGeometry(isWhite: Bool) -> SCNNode {
        let parent = SCNNode()

        // 底座
        let base = SCNCylinder(radius: 0.28, height: 0.1)
        let baseMat = SCNMaterial()
        baseMat.diffuse.contents = isWhite ? NSColor.white : NSColor.black
        base.materials = [baseMat]
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.05, 0)
        parent.addChildNode(baseNode)

        // 塔身
        let body = SCNCylinder(radius: 0.22, height: 0.4)
        body.materials = [baseMat]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(0, 0.3, 0)
        parent.addChildNode(bodyNode)

        // 顶部
        let top = SCNCylinder(radius: 0.26, height: 0.1)
        top.materials = [baseMat]
        let topNode = SCNNode(geometry: top)
        topNode.position = SCNVector3(0, 0.55, 0)
        parent.addChildNode(topNode)

        return parent
    }

    private func createKnightGeometry(isWhite: Bool) -> SCNNode {
        let parent = SCNNode()

        let mat = SCNMaterial()
        mat.diffuse.contents = isWhite ? NSColor.white : NSColor.black

        // 底座
        let base = SCNCylinder(radius: 0.25, height: 0.1)
        base.materials = [mat]
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.05, 0)
        parent.addChildNode(baseNode)

        // 马身（椭圆）
        let body = SCNCapsule(capRadius: 0.15, height: 0.4)
        body.materials = [mat]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(0, 0.3, 0)
        bodyNode.eulerAngles.z = .pi / 2
        parent.addChildNode(bodyNode)

        // 马头
        let head = SCNSphere(radius: 0.12)
        head.materials = [mat]
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0.2, 0.5, 0)
        parent.addChildNode(headNode)

        return parent
    }

    private func createBishopGeometry(isWhite: Bool) -> SCNNode {
        let parent = SCNNode()

        let mat = SCNMaterial()
        mat.diffuse.contents = isWhite ? NSColor.white : NSColor.black

        // 底座
        let base = SCNCylinder(radius: 0.25, height: 0.1)
        base.materials = [mat]
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.05, 0)
        parent.addChildNode(baseNode)

        // 杆
        let body = SCNCylinder(radius: 0.12, height: 0.45)
        body.materials = [mat]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(0, 0.32, 0)
        parent.addChildNode(bodyNode)

        // 顶部球体
        let top = SCNSphere(radius: 0.18)
        top.materials = [mat]
        let topNode = SCNNode(geometry: top)
        topNode.position = SCNVector3(0, 0.6, 0)
        parent.addChildNode(topNode)

        // 十字装饰
        let cross = SCNCapsule(capRadius: 0.04, height: 0.2)
        cross.materials = [mat]
        let crossNode = SCNNode(geometry: cross)
        crossNode.position = SCNVector3(0, 0.78, 0)
        parent.addChildNode(crossNode)

        return parent
    }

    private func createQueenGeometry(isWhite: Bool) -> SCNNode {
        let parent = SCNNode()

        let mat = SCNMaterial()
        mat.diffuse.contents = isWhite ? NSColor.white : NSColor.black

        // 底座
        let base = SCNCylinder(radius: 0.3, height: 0.12)
        base.materials = [mat]
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.06, 0)
        parent.addChildNode(baseNode)

        // 裙摆
        let skirt = SCNCone(topRadius: 0.28, bottomRadius: 0.22, height: 0.3)
        skirt.materials = [mat]
        let skirtNode = SCNNode(geometry: skirt)
        skirtNode.position = SCNVector3(0, 0.27, 0)
        parent.addChildNode(skirtNode)

        // 身体
        let body = SCNCylinder(radius: 0.18, height: 0.35)
        body.materials = [mat]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(0, 0.55, 0)
        parent.addChildNode(bodyNode)

        // 头部
        let head = SCNSphere(radius: 0.2)
        head.materials = [mat]
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 0.85, 0)
        parent.addChildNode(headNode)

        // 皇冠
        let crown = SCNCone(topRadius: 0.05, bottomRadius: 0.18, height: 0.15)
        crown.materials = [mat]
        let crownNode = SCNNode(geometry: crown)
        crownNode.position = SCNVector3(0, 1.02, 0)
        parent.addChildNode(crownNode)

        return parent
    }

    private func createKingGeometry(isWhite: Bool) -> SCNNode {
        let parent = SCNNode()

        let mat = SCNMaterial()
        mat.diffuse.contents = isWhite ? NSColor.white : NSColor.black

        // 底座
        let base = SCNCylinder(radius: 0.32, height: 0.12)
        base.materials = [mat]
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.06, 0)
        parent.addChildNode(baseNode)

        // 身体
        let body = SCNCylinder(radius: 0.2, height: 0.5)
        body.materials = [mat]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(0, 0.37, 0)
        parent.addChildNode(bodyNode)

        // 头部
        let head = SCNSphere(radius: 0.2)
        head.materials = [mat]
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 0.75, 0)
        parent.addChildNode(headNode)

        // 皇冠
        let crownBase = SCNCylinder(radius: 0.22, height: 0.08)
        crownBase.materials = [mat]
        let crownBaseNode = SCNNode(geometry: crownBase)
        crownBaseNode.position = SCNVector3(0, 0.92, 0)
        parent.addChildNode(crownBaseNode)

        let crownTop = SCNCone(topRadius: 0.02, bottomRadius: 0.18, height: 0.2)
        crownTop.materials = [mat]
        let crownTopNode = SCNNode(geometry: crownTop)
        crownTopNode.position = SCNVector3(0, 1.1, 0)
        parent.addChildNode(crownTopNode)

        return parent
    }

    private func handleClickAt(_ location: NSPoint) {
        print("Click at: \(location)")

        let hitResults = scnView.hitTest(location, options: [
            .searchMode: SCNHitTestSearchMode.all.rawValue,
            .ignoreHiddenNodes: true,
            .boundingBoxOnly: false
        ])

        print("Hit results count: \(hitResults.count)")
        for result in hitResults {
            var node: SCNNode? = result.node
            var path = ""
            while let n = node {
                path = "/" + (n.name ?? "unnamed") + path
                node = n.parent
            }
            print("  Hit: \(path)")
        }

        // 遍历点击结果，向上查找直到找到有名称的节点
        for result in hitResults {
            var node: SCNNode? = result.node

            // 向上遍历父节点查找名称
            while let currentNode = node {
                if let nodeName = currentNode.name {
                    // 检查是否点击了棋子
                    if nodeName.hasPrefix("piece_") {
                        let components = nodeName.components(separatedBy: "_")
                        if components.count >= 3,
                           let row = Int(components[1]),
                           let col = Int(components[2]) {
                            handlePieceClick(row: row, col: col)
                            return
                        }
                    }

                    // 检查是否点击了格子
                    if nodeName.hasPrefix("square_") {
                        let components = nodeName.components(separatedBy: "_")
                        if components.count >= 3,
                           let row = Int(components[1]),
                           let col = Int(components[2]) {
                            handleSquareClick(row: row, col: col)
                            return
                        }
                    }
                }
                node = currentNode.parent
            }
        }

        // 点击空白处取消选择
        clearSelection()
    }

    private func handlePieceClick(row: Int, col: Int) {
        let currentPlayer = gameManager.currentPlayer
        let location = BoardLocation(x: col, y: 7 - row)

        // 检查是否点击了当前玩家的棋子
        if let piece = gameManager.board.getPiece(at: location),
           piece.color == currentPlayer {

            // 选中这个棋子
            selectedSquare = (row, col)

            // 获取有效移动
            validMoves = gameManager.getValidMoves(for: ChessSquare(row: row, col: col))

            // 显示高亮
            showValidMoves(validMoves)
        } else {
            // 可能是移动到对方棋子 - 检查是否是有效移动
            if let fromSquare = selectedSquare {
                if isValidMove(toRow: row, toCol: col) {
                    movePiece(from: fromSquare, to: (row, col))
                }
            }
        }
    }

    private func handleSquareClick(row: Int, col: Int) {
        if let fromSquare = selectedSquare {
            if isValidMove(toRow: row, toCol: col) {
                movePiece(from: fromSquare, to: (row, col))
            } else {
                // 检查是否点击了其他己方棋子
                let location = BoardLocation(x: col, y: 7 - row)
                if let piece = gameManager.board.getPiece(at: location),
                   piece.color == gameManager.currentPlayer {
                    // 切换选中
                    selectedSquare = (row, col)
                    validMoves = gameManager.getValidMoves(for: ChessSquare(row: row, col: col))
                    showValidMoves(validMoves)
                } else {
                    clearSelection()
                }
            }
        }
    }

    private func isValidMove(toRow: Int, toCol: Int) -> Bool {
        return validMoves.contains { $0.row == toRow && $0.col == toCol }
    }

    private func movePiece(from: (row: Int, col: Int), to: (row: Int, col: Int)) {
        let fromSquare = ChessSquare(row: from.row, col: from.col)
        let toSquare = ChessSquare(row: to.row, col: to.col)

        // 检查是否需要升变
        let fromLocation = BoardLocation(x: from.col, y: 7 - from.row)
        if let piece = gameManager.board.getPiece(at: fromLocation),
           piece.type == .pawn && to.row == (piece.color == .white ? 0 : 7) {
            // 兵升变 - 默认升变为后
            gameManager.movePiece(from: fromSquare, to: toSquare, promotion: .queen)
        } else {
            gameManager.movePiece(from: fromSquare, to: toSquare)
        }

        clearSelection()
    }

    private func showValidMoves(_ moves: [(row: Int, col: Int)]) {
        clearHighlights()

        for move in moves {
            let highlightGeometry = SCNCylinder(radius: 0.3, height: 0.05)
            let highlightMat = SCNMaterial()
            highlightMat.diffuse.contents = NSColor(calibratedRed: 0.2, green: 0.8, blue: 0.2, alpha: 0.5)
            highlightMat.emission.contents = NSColor(calibratedRed: 0.1, green: 0.4, blue: 0.1, alpha: 0.3)
            highlightGeometry.materials = [highlightMat]

            let highlightNode = SCNNode(geometry: highlightGeometry)
            highlightNode.position = SCNVector3(
                Float(move.col) - boardSize / 2 + 0.5,
                0.05,
                Float(move.row) - boardSize / 2 + 0.5
            )
            highlightNode.name = "highlight_\(move.row)_\(move.col)"

            boardNode.addChildNode(highlightNode)
            highlightNodes.append(highlightNode)
        }
    }

    private func clearHighlights() {
        for node in highlightNodes {
            node.removeFromParentNode()
        }
        highlightNodes.removeAll()
    }

    private func clearSelection() {
        selectedSquare = nil
        validMoves.removeAll()
        clearHighlights()
    }

    func resetCamera() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5

        let distance: Float = 14.0
        let angle: Float = .pi / 6
        cameraNode.position = SCNVector3(
            distance * cos(angle),
            distance * 0.8,
            distance * sin(angle)
        )
        cameraNode.look(at: SCNVector3(0, 0, 0))

        SCNTransaction.commit()
    }
}
