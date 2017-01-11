//
//  XBBannerViewCell.swift
//  XBBannerView
//
//  Created by xxb on 2016/12/6.
//  Copyright © 2016年 xxb. All rights reserved.
//

import UIKit

class XBBannerViewCell: UICollectionViewCell {
    
    let imageV = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageV)
        imageV.frame=CGRect(x:0,y:0,width:frame.size.width,height:frame.size.height)
        imageV.image=UIImage(named: "1.png")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
