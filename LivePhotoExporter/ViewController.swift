//
//  ViewController.swift
//  LivePhotoExporter
//
//  Created by Tomas Harkema on 11-10-15.
//  Copyright © 2015 Tomas Harkema. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Regift

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

  @IBOutlet weak var livePhotoView: UIView!

  var liveView: PHLivePhotoView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    view.layoutIfNeeded()
    liveView = PHLivePhotoView(frame: livePhotoView.bounds)
    livePhotoView.addSubview(liveView)
    liveView.contentMode = .ScaleAspectFit
  }

  @IBAction func chooseImagePressed(sender: AnyObject) {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .PhotoLibrary
    imagePicker.delegate = self
    presentViewController(imagePicker, animated: true, completion: nil)
  }

  @IBAction func exportPressed(sender: AnyObject) {
    if let livePhoto = liveView.livePhoto {
      exportLivePhoto(livePhoto)
    }
  }

  func createGifFromVideoUrl(url: NSURL) {
    let regift = Regift(sourceFileURL: url, frameCount: 25, delayTime: 0).createGif()
    if let dataUrl = regift {
      let data = NSData(contentsOfURL: dataUrl)!

      dispatch_async(dispatch_get_main_queue()) {
        let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
      }
    }
  }

  func exportLivePhoto(livePhoto: PHLivePhoto) {
    let resources = PHAssetResource.assetResourcesForLivePhoto(livePhoto).filter { $0.type == .PairedVideo }
    if let resource = resources.first {
      let options = PHAssetResourceRequestOptions()

      let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
      let guid = NSUUID().UUIDString
      let url = folder.URLByAppendingPathComponent("\(guid)-livePhoto.MOV")
      PHAssetResourceManager.defaultManager().writeDataForAssetResource(resource, toFile: url, options: options, completionHandler: { (error) in
        if let error = error { print(error)
          return }
          self.createGifFromVideoUrl(url)
      })
    }
  }

  func livePhotoSelected(livePhoto: PHLivePhoto) {
    liveView.livePhoto = livePhoto
    liveView.startPlaybackWithStyle(PHLivePhotoViewPlaybackStyle.Full)
  }

  func fetchImageFromURL(url: NSURL) {
    let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as! PHAsset
    let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)

    PHImageManager.defaultManager().requestLivePhotoForAsset(asset, targetSize: size, contentMode: PHImageContentMode.Default, options: nil) { (livePhoto, options) in
      if let livePhoto = livePhoto {
        self.livePhotoSelected(livePhoto)
      } else {
        self.alertNoLivePhoto()
      }
    }
  }

  func alertNoLivePhoto() {
    let alertController = UIAlertController(title: "No Live Photo!", message: "Please, select an live-photo!", preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default) { action in
      alertController.dismissViewControllerAnimated(true, completion: nil)
      self.chooseImagePressed(self.view)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
      alertController.dismissViewControllerAnimated(true, completion: nil)
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    presentViewController(alertController, animated: true, completion: nil)
  }

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    picker.dismissViewControllerAnimated(true) {
      if let url = info[UIImagePickerControllerReferenceURL] as? NSURL {
        self.fetchImageFromURL(url)
      }
    }
  }

  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }

  func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    return self
  }

}

