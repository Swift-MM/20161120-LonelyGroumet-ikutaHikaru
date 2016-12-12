//
//  ExtensionViewController.swift
//  avCapturePhoto_simple
//
//  Created by yoshiyuki oshige on 2016/09/26.
//  Copyright © 2016年 yoshiyuki oshige. All rights reserved.
//

import Photos

// デリゲート部分を拡張する
extension ViewController:AVCapturePhotoCaptureDelegate {
    // 映像をキャプチャする
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                 previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        
        // バッファからjpegデータを取り出す
        let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
            forJPEGSampleBuffer: photoSampleBuffer!,
            previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        //　photoDataがnilでないときUIImageに変換する
        if let data = photoData {
            if let stillImage = UIImage(data: data) {
                // アルバムに追加する
                UIImageWriteToSavedPhotosAlbum(stillImage, self, nil, nil)
            }
        }
    }
}
