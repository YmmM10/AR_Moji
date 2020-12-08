//
//  ViewController.swift
//  moji
//
//  Created by amalab on 2020/11/17.
//
import UIKit
import SceneKit
import ARKit

class BubbleViewController: UIViewController, ARSCNViewDelegate {
    
    //サーバーのURL
    let URL = "http://192.168.1.19:3000/messages/2"
    
    @IBOutlet var sceneView: ARSCNView!
    //aaaの意味は知らん。多分とりあえず入れただけ。
    //extrusionDepthは文字の厚さ
    var text: SCNText = SCNText(string: "aaa", extrusionDepth: 0.2)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // シーンを生成
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // 必要に応じて自動的に光源が追加されるように設定
        sceneView.autoenablesDefaultLighting = true
        
        // デバッグ用設定
        // バウンディングボックス、ワイヤーフレームを表示する
        //これがあると文字の周りに白い四角が表示される
        //sceneView.debugOptions = [.showBoundingBoxes, .showWireframe]
    }
    
    func requestApi(urlString: String) -> String {
        //プログラムがどの順番で動いてるか確認するために入れた言葉
        print(urlString)
        self.text.string = "ちょまてよ"
        
        
        let url: URL = Foundation.URL(string: urlString)!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            // 動いているか確認するためにコンソールに出力する処理
            //なにしてるかよく分かっていません。
            print("data: \(String(describing: data))")
            print("response: \(String(describing: response))")
            print("error: \(String(describing: error))")
            do{
                let messageData = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                print(messageData?["text"] as! String)
                self.text.string = messageData?["text"] as! String
            }
            catch {
                print(error)
            }
            
        })
        task.resume()
        
        return urlString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //ARImageTrackingConfigurationの生成
        let configuration = ARImageTrackingConfiguration()
        
        //画像マーカーのリソースの指定
        configuration.trackingImages = ARReferenceImage.referenceImages(
            inGroupNamed: "AR Resources", bundle: nil)!
        
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            //ARAnchorの名前がbubbleの時
            //指定した画像(今回は石鹸の画像:ファイル名はbubbleにした)
            if (anchor.name == "bubble") {
                print("まこちゃん参上")
                // 表示するテキストを用意
                let str = self.requestApi(urlString: self.URL)
                let depth:CGFloat = 0.2 // 奥行き0.2m
                self.text = SCNText(string: str, extrusionDepth: depth)
                //self.text.chamferRadius = 2.0
                self.text.flatness = 0.01
                self.text.font = UIFont.systemFont(ofSize: 1.0)
                // AR空間にテキスト要素を配置
                node.addChildNode(self.creatTextNode())
                print("node.addChildNode(self.creatTextNode())")
            }
        }
    }
    
    //この辺消してもアプリ動いたし、何してんのか分からない。
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    //この辺消してもアプリ動いたし、何してんのか分からない。
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    //この辺消してもアプリ動いたし、何してんのか分からない。
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func creatTextNode() -> SCNNode{
        // テキストの色と質感を用意
        // SCNText には最大5つの要素があり、それぞれに SCNMaterial を指定できる
        // front, back, extruded sides, front chamfer, back chamfer
        // front material
        let m1 = SCNMaterial()
        //色の指定方法1
        //m1.diffuse.contents = UIColor.red
        //色の指定方法2
        m1.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        // 鏡面反射感を出す
        m1.lightingModel = .physicallyBased
        //表面がどのくらい金属的に見えるかの調整をしたの三文でする
        m1.metalness.contents = 0.01
        //マテリアルのmatalnessとroughnessを指定して金属感を調整している
        m1.metalness.intensity = 1.0
        m1.roughness.intensity = 0.0
        // back material
        let m2 = SCNMaterial()
        m2.diffuse.contents = UIColor.red
        m2.lightingModel = .physicallyBased
        m2.metalness.contents = 1.0
        m2.metalness.intensity = 1.0
        m2.roughness.intensity = 0.0
        // extruded sides material
        let m3 = SCNMaterial()
        m3.diffuse.contents = UIColor.red
        m3.lightingModel = .physicallyBased
        m3.metalness.contents = 1.0
        m3.metalness.intensity = 1.0
        m3.roughness.intensity = 0.0
        // front chamfer material
        //正面の面取りを変えているけど、色変えても違いがよくわからなかった。
        let m4 = SCNMaterial()
        m4.diffuse.contents = UIColor.blue
        // back chamfer material
        //裏の面取りを変えているけど、色変えても違いがよくわからなかった。
        let m5 = SCNMaterial()
        m5.diffuse.contents = UIColor.blue
        
        // 上で指定したテキストの色と質感をセット
        self.text.materials = [m1, m2, m3, m4, m5]
        
        // AR空間の要素としてテキストをセット
        let textNode = SCNNode(geometry: self.text)
        //文字の大きさを指定している
        let scale = 0.015
        textNode.scale = SCNVector3(scale,scale,scale)
        
        return textNode
    }
}
