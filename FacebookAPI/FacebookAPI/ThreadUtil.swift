//
//  ThreadUtil.swift
//  MoneyControll
//
//  Created by yuya on 2016/05/07.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

class ThreadUtil{
    
    // プライベートキューの発行。
    private static let private_queue = dispatch_queue_create("jp.test.sample", DISPATCH_QUEUE_SERIAL);
    
    /// If the thread is main thread, f() function is executed just. If not, this method calls dispatch_get_main_queue and f() function will be executed on MainThread. That is, this method ensures f() is executed on MainThread.
    /// - parameter f(): This method is exuceted on MainThread certainly.
    static func dipatch_async_main(f:() -> ()){
        if NSThread.isMainThread(){
            f()
        }else{
            let main = dispatch_get_main_queue()
            dispatch_async(main, {
                f()
            })
        }
    }
    
    
    
    
    
    static func dipatch_async_sub(){
        let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_DEFAULT
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            // Backgroundで行いたい重い処理はここ
            
            dispatch_async(dispatch_get_main_queue(), {
                // 処理が終わった後UIスレッドでやりたいことはここ
            })
        })
    }
}