//
//  XBBannerView.swift
//  XBBannerView
//
//  Created by xxb on 2016/12/6.
//  Copyright © 2016年 xxb. All rights reserved.
//

import UIKit
import Kingfisher

let mulCount = 16
let autoTime = 4
let pageControlH = 20


protocol XBBannerViewDelegate:NSObjectProtocol {
    func bannerView(bannerView:XBBannerView, clickAt index:NSInteger) ->Void
}


class XBBannerView: UIView{
    
    fileprivate lazy var adCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection=UICollectionViewScrollDirection.horizontal
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        
        let collectionV = UICollectionView(frame: CGRect(x:0,y:0,width:self.frame.size.width,height:self.frame.size.height), collectionViewLayout: layout)
        collectionV.delegate=self
        collectionV.dataSource=self
        collectionV.register(XBBannerViewCell.self, forCellWithReuseIdentifier: "XBBannerViewCell")
        collectionV.isPagingEnabled=true
        collectionV.showsVerticalScrollIndicator=false
        collectionV.showsHorizontalScrollIndicator=false
        return collectionV
    }()
    
    fileprivate lazy var pageControl:UIPageControl = {
        let pageControl=UIPageControl()
        pageControl.frame=CGRect(x: 0, y: self.frame.size.height-CGFloat(pageControlH), width: self.frame.size.width, height: CGFloat(pageControlH))
        pageControl.backgroundColor=UIColor.black.withAlphaComponent(0.3)
        return pageControl
    }()
    
    fileprivate let selfFrame:CGRect!
    
    var placeholderImageName:String?
    
    weak var delegate:XBBannerViewDelegate?
    
    fileprivate var timer:Timer?
    
    fileprivate var pageIndex:NSInteger?
    
    fileprivate var _imageUrlArr=["bannerViewLoading.jpg"]
    
    var imageUrlArr:[String] {
        get{return _imageUrlArr}
        set{
            if (newValue.count>0) == false {
                return
            }
            _imageUrlArr=newValue
            pageControl.numberOfPages=_imageUrlArr.count
            adCollectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline:
                DispatchTime.now()
                    + 0.05){
                        print("hehehehe")
                        self.pageIndex=self._imageUrlArr.count * mulCount / 2
                        self.scrollToPageIndex(animated: false)
                        self.sameDemoAterScroll(scrollView: self.adCollectionView)
                        self.setupTimer()
            }
        }
    }
    
    override init(frame: CGRect) {
        selfFrame=frame
        super.init(frame: frame)
        addSubview(adCollectionView)
        addSubview(pageControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //子类重写
    func setParamsWithIndex(index:NSInteger) -> Void {
        
    }
}

extension XBBannerView:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _imageUrlArr.count * mulCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:XBBannerViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "XBBannerViewCell", for: indexPath) as! XBBannerViewCell
        
        
        if _imageUrlArr[0]=="bannerViewLoading.jpg"
        {
            cell.imageV.image=UIImage(named: "\(_imageUrlArr[0])")
        }
        else
        {
            let url = URL(string: "\(_imageUrlArr[indexPath.item % _imageUrlArr.count])")
            cell.imageV.kf.setImage(with: url, placeholder: UIImage(named: "\(placeholderImageName ?? "bannerViewLoading.jpg")"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return selfFrame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if delegate != nil{
            delegate!.bannerView(bannerView: self, clickAt: pageIndex! % _imageUrlArr.count)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setupTimer()
        sameDemoAterScroll(scrollView: scrollView)
    }
    
    func scrollToPageIndex(animated:Bool) -> Void {
        adCollectionView.scrollToItem(at: IndexPath(item: pageIndex!, section: 0), at: UICollectionViewScrollPosition.left, animated: animated)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        sameDemoAterScroll(scrollView: scrollView)
    }
    
    fileprivate func sameDemoAterScroll(scrollView:UIScrollView) -> Void {
        pageIndex = Int(scrollView.contentOffset.x) / Int(selfFrame.size.width)
        fixIndex()
        scrollToPageIndex(animated: false)
        setParams()
    }
    
    private func setParams()->Void{
        let index = pageIndex! % _imageUrlArr.count
        pageControl.currentPage=index
        //do someThing
        print(index)
        
        setParamsWithIndex(index: index)
    }
    
    fileprivate func setupTimer() -> Void{
        if timer != nil{
            timer?.invalidate()
        }
        timer=Timer(timeInterval: TimeInterval(autoTime), target: self, selector: #selector(XBBannerView.autoNextPage), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    private func stopTimer() -> Void {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func autoNextPage() -> Void{
        //        print("自动翻页")
        //避免出现看见倒着从最后一张滚到第一张
        fixIndex()
        scrollToPageIndex(animated: false)
        
        pageIndex! += 1
        scrollToPageIndex(animated: true)
    }
    
    private func fixIndex() ->Void{
        if (pageIndex! >= _imageUrlArr.count * (mulCount-3)) || (pageIndex! <= _imageUrlArr.count * 3){
            pageIndex=_imageUrlArr.count * mulCount / 2
        }
    }
}
