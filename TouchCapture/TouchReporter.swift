//
//  TouchReporter.swift
//  TouchCapture
//
//  Created by Mathew Miller on 11/17/18.
//  Copyright © 2018 Mathew Miller. All rights reserved.
//

import Foundation
import UIKit

enum GestureType: String, CaseIterable {
    case pinch = "Pinch"
    case pan = "Pan"
    case swipe = "Swipe"
    case markup = "Markup"
}

struct Touch {
    let startPoint: CGPoint
    let startTime: TimeInterval
    var radius: CGFloat
    var pointCount: Int
    var currentPoint: CGPoint
    var currentTime: TimeInterval
    
    init(touch: UITouch, inView: UIView) {
        startPoint = touch.location(in: inView)
        startTime = touch.timestamp
        radius = touch.majorRadius
        pointCount = 1
        currentPoint = startPoint
        currentTime = startTime
    }
    
    mutating func update(withTouch touch: UITouch, inView: UIView) {
        currentPoint = touch.location(in: inView)
        currentTime = touch.timestamp
        radius = touch.majorRadius
        pointCount += 1
    }
    
    var timeDelta: TimeInterval {
        return currentTime - startTime
    }
}

struct TouchReporter {

    
    static let endpoint: URL? = {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dic = NSDictionary(contentsOfFile: path)
            if let serverIp = dic?["SERVER_IP"] {
                return URL(string: "http://\(serverIp):3000")
            }
        }
        
        return URL(string: "http://127.0.0.1:3000")
    }()
    
    var touchMap = [UITouch: Touch]()
    
    init(_ touches: Set<UITouch>, inView view: UIView) {
        for touch in touches {
            let recordedTouch = Touch(touch: touch, inView: view)
            touchMap[touch] = recordedTouch
        }
    }

    mutating func updateTouches(_ touches: Set<UITouch>, inView view: UIView) {
        
        var touchOne: Touch?
        var touchTwo: Touch?
        
        for touch in touches {
            if var recordedTouch = touchMap[touch] {
                recordedTouch.update(withTouch: touch, inView: view)
                touchMap[touch] = recordedTouch
                
                if touchOne == nil {
                    touchOne = recordedTouch
                } else if touchTwo == nil {
                    touchTwo = recordedTouch
                }
                
            } else {
                let recordedTouch = Touch(touch: touch, inView: view)
                touchMap[touch] = recordedTouch
                
                if touchOne == nil {
                    touchOne = recordedTouch
                } else if touchTwo == nil {
                    touchTwo = recordedTouch
                }
            }
        }
        
        if let touchOne = touchOne {
            recordGesture(withTouchOne: touchOne, andTouchTwo: touchTwo)
        }
    }
    
    func recordGesture(withTouchOne touchOne: Touch, andTouchTwo touchTwo: Touch?) {
        
        let t1p1 = touchOne.startPoint
        let t1p2 = touchOne.currentPoint

        var json: [String:Any] = [
            "markupMode": Settings.markupModeOn ? "true": "false",
            "t1p1x": t1p1.x,
            "t1p1y": t1p1.y,
            "t1p2x": t1p2.x,
            "t1p2y": t1p2.y,
            "t1Radius": touchOne.radius,
            "t1TimeDelta": touchOne.timeDelta,
            "isMarkup": Settings.gestureType == .markup ? "true" : "false"
        ]

        if let touchTwo = touchTwo {
            let t2p1 = touchTwo.startPoint
            let t2p2 = touchTwo.currentPoint

            json["t2p1x"] = t2p1.x
            json["t2p1y"] = t2p1.y
            json["t2p2x"] = t2p2.x
            json["t2p2y"] = t2p2.y
            json["t2Radius"] = touchTwo.radius
            json["t2TimeDelta"] = touchTwo.timeDelta
        } else {
            json["t2p1x"] = -1.0
            json["t2p1y"] = -1.0
            json["t2p2x"] = -1.0
            json["t2p2y"] = -1.0
            json["t2Radius"] = -1.0
            json["t2TimeDelta"] = -1.0
        }

        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            postData(data)
        }
    }
    
    func postData(_ data: Data) {
        if let endpoint = TouchReporter.endpoint {
            
            var request = URLRequest(url: endpoint)
            request.httpBody = data
            request.httpMethod = "POST"
            let update = URLSession.shared.dataTask(with: request)
            
            update.resume()
        }
    }
    
}
