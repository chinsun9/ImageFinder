//
//  DetailImageViewController.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/11.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit
import WebKit
import DropDown


class DetailImageViewController: UIViewController, UIScrollViewDelegate {

    var document: NSDictionary = [:]
    var url: String = ""
    var imageUrl: String = ""
    var isHideImage: Bool = false
    
     let rightBarDropDown = DropDown()
    
    
    // 사진 정보 팝업용 뷰
    var popUpWindow: PopUpWindow!
    
    
       
    @IBOutlet var myWebView: WKWebView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var btnBar: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillDisappear(true)
        myWebView.scrollView.delegate = self
        
        print(document)
        
        // 이미지 세팅
        setImage()
        
        // 페이지 로드
        setWeb()
        
        // 바버튼 기능

        rightBarDropDown.anchorView = btnBar
        rightBarDropDown.dataSource = ["공유", "정보", "다운로드"]
        rightBarDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        
    
    }
    
        override func viewWillDisappear(_ animated: Bool) {
               super.viewWillDisappear(animated)
               navigationController?.setNavigationBarHidden(false, animated: animated)
           }
    
    
    
    func setImage() {
        imageView.downloaded(from: document.value(forKeyPath: "image_url") as! String)
    }
    
    func setWeb() {
        loadWebPate(document.value(forKeyPath: "doc_url") as! String)
    }
    
    // 웹뷰 스크롤하면 이미지 감추기

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if (!isHideImage && scrollView.contentOffset.y >= 120) {
//            print(imageView.constraints)
            isHideImage.toggle()
            hideImage(isHideImage)
        } else if (isHideImage && scrollView.contentOffset.y < 120) {
            isHideImage.toggle()
            hideImage(isHideImage)
        }
        
    }
    
    func hideImage(_ isHide: Bool) {
        self.view.layoutIfNeeded() // force any pending operations to finish

        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let height: CGFloat = isHide ? 0 : 400
            self.imageView.constraints[2].constant = height
            self.view.layoutIfNeeded()
        })
    }
    

    
    
    func loadWebPate(_ url: String){
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url:myUrl!)
        myWebView.load(myRequest)
    }
  
    
    @IBAction func showBarButtonDropDown(_ sender: UIBarButtonItem) {rightBarDropDown.selectionAction = {
            (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
        // 공유, 정보, 다운로드
        switch index {
        case 0:
            let activityController = UIActivityViewController(activityItems: [self.document.value(forKeyPath: "image_url") as Any], applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
            
            break
        case 1:
            var text = "범주 : "
            text += self.document.value(forKeyPath: "collection") as! String
            text += "\n"
            
            text += "개시된 사이트 : "
            text += self.document.value(forKeyPath: "display_sitename") as! String
            text += "\n"
            
            text += "개시된 날짜 : "
            text += self.document.value(forKeyPath: "datetime") as! String
            text += "\n"
            
            
            text += "사진크기 : "
            text += (self.document.value(forKeyPath: "width") as! NSNumber).stringValue
            text += "x"
            text += (self.document.value(forKeyPath: "height") as! NSNumber).stringValue
               
            
            self.popUpWindow = PopUpWindow(title: "이미지 정보", text: text, buttontext: "닫기")
            self.present(self.popUpWindow, animated: true, completion: nil)
            break
        case 2:
            

            if let url = URL(string: self.document.value(forKeyPath: "image_url") as! String),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                print("image download")
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                

                self.showToast(message: "이미지 저장완료", font: .systemFont(ofSize: 12.0))
            }
            
            break
        default:
            print("no way")
        }
            
        }
        
        rightBarDropDown.width = 140
        rightBarDropDown.bottomOffset = CGPoint(x: 0, y:(rightBarDropDown.anchorView?.plainView.bounds.height)!)
        rightBarDropDown.show()
    }
    
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
