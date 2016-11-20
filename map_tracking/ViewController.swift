//
//  ViewController.swift
//  map_tracking
//
//  Created by yoshiyuki oshige on 2016/09/28.
//  Copyright © 2016年 yoshiyuki oshige. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    // 地図
    @IBOutlet weak var mapView: MKMapView!
    
    // UserDefaultsの保存・読み込み時に使う名前
    let userDefName = "pins"
    
    
    
    // トラッキングボタン
    @IBOutlet weak var trackingButton: UIBarButtonItem!
    
    //長押しした時の動作
    @IBAction func longTapButton(_ sender: UILongPressGestureRecognizer) {
        
        //sender.stateは関数が呼ばれた時のジェスチャーを格納
        if (sender as AnyObject).state != UIGestureRecognizerState.began{
            return
        }
        
        
        
        // 位置情報を取得します。
        let point = sender.location(in: mapView)
        let geo = mapView.convert(point, toCoordinateFrom: mapView)
        
        // アラートの作成
        let alert = UIAlertController(title: "スポット登録", message: "この場所に残すメッセージを入力してください。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "登録", style: .default, handler: { (action: UIAlertAction) -> Void in
            
            
            let pin = Pin(geo: geo, text: alert.textFields?.first?.text)
            self.mapView.addAnnotation(pin)
            self.savePin(pin)
            
            
        }))
        
        // ピンに登録するテキスト用の入力フィールドをアラートに追加します。
        alert.addTextField(configurationHandler: { (textField: UITextField) in
            textField.placeholder = "メッセージ"
        })
        
        // アラートの表示
        present(alert, animated: true, completion: nil)
        
    }
    
    // ロケーションマネージャを作る
    var locationManager = CLLocationManager()
    
    
    // トラッキングモードを切り替える
    @IBAction func tapTrackingButton(_ sender: UIBarButtonItem) {
        switch mapView.userTrackingMode {
        case .none:
            // noneからfollowへ
            mapView.setUserTrackingMode(.follow, animated: true)
            // トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingFollow")
        case .follow:
            // followからfollowWithHeadingへ
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            // トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingHeading")
        case .followWithHeading:
            // followWithHeadingからnoneへ
            mapView.setUserTrackingMode(.none, animated: true)
            // トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingNone")
        }
    }
    
    // トラッキングが自動解除された
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        // トラッキングボタンを変更する
        trackingButton.image = UIImage(named: "trackingNone")
    }
    
    
    // 位置情報利用許可のステータスが変わった
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse :
            // ロケーションの更新を開始する
            locationManager.startUpdatingLocation()
            // トラッキングボタンを有効にする
            trackingButton.isEnabled = true
        default:
            // ロケーションの更新を停止する
            locationManager.stopUpdatingLocation()
            // トラッキングモードをnoneにする
            mapView.setUserTrackingMode(.none, animated: true)
            //トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingNone")
            // トラッキングボタンを無効にする
            trackingButton.isEnabled = false
        }
    }
    
    // ピンの保存
    func savePin(_ pin: Pin) {
        let userDefaults = UserDefaults.standard
        
        // 保存するピンをUserDefaults用に変換します。
        let pinInfo = pin.toDictionary()
        
        if var savedPins = userDefaults.object(forKey: userDefName) as? [[String: Any]] {
            // すでにピン保存データがある場合、それに追加する形で保存します。
            savedPins.append(pinInfo)
            userDefaults.set(savedPins, forKey: userDefName)
            
        } else {
            // まだピン保存データがない場合、新しい配列として保存します。
            let newSavedPins: [[String: Any]] = [pinInfo]
            userDefaults.set(newSavedPins, forKey: userDefName)
        }
    }

    
    
    
    // 既に保存されているピンを取得
    func loadPins() {
        let userDefaults = UserDefaults.standard
        
        if let savedPins = userDefaults.object(forKey: userDefName) as? [[String: Any]] {
            
            // 現在のピンを削除
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            
            for pinInfo in savedPins {
                let newPin = Pin(dictionary: pinInfo)
                self.mapView.addAnnotation(newPin)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // アプリ利用中の位置情報の利用許可を得る
        locationManager.requestWhenInUseAuthorization()
        // ロケーションマネージャのデリゲートになる
        locationManager.delegate = self
        // myMapのデリゲートになる
        mapView.delegate = self
        // スケールを表示する
        mapView.showsScale = true
        
        // 保存されているピンを配置
        loadPins()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
