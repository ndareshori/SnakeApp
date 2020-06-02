//
//  SnakeCopies.swift
//  Snake
//
//  Created by Nick Dareshori on 5/28/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import Foundation

class SnakeCopies {
    private var copy1: [Segment] = [Segment]()
    private var copy2: [Segment] = [Segment]()
    private var copy3: [Segment] = [Segment]()
    private var copies: [[Segment]] = [[Segment]]()
    
    enum currentlyViewing {
        case none
        case c1
        case c2
        case c3
    }
    
    init() {
        copies.append(copy1)
        copies.append(copy2)
        copies.append(copy3)
    }
    private var currentView = currentlyViewing.none
    
//    enum lastCopiedTo {
//        case firstCopy
//        case copy1
//        case copy2
//        case copy3
//        case fullCopies
//    }
//    private var lastCopy = lastCopiedTo.firstCopy //keeps track of what the last copy was
    
    func makeCopy(snake: [Segment]) {
        copy1 = [Segment]()
        if copy1.isEmpty {
        } else if copy2.isEmpty {
            copy2 = copy1
        } else {
            copy3 = copy2
            copy2 = copy1
        }
        print("copied:")
        for segment in snake {
            let copiedSegment = segment.copy() as! Segment
            copy1.append(copiedSegment)
            print(copiedSegment.getSegment().position)
        }
        print("why u empty:")
        for segment in copy1 {
            print(segment.getSegment().position)
//            scene.addChild(segment.getSegment())
        }
    }
    
    func showCopies(scene: GameScene) {
        currentView = .c1
        for seg in copy1 {
            scene.addChild(seg.getSegment())
        }
    }
    
    func bprint() {
        for seg in copy1{
            print(seg.getSegment().position)
        }
    }
    
    //Parameters: 0 for left, 1 for right
    func moveViews(scene: GameScene, side: Int) {
        if currentView == .c1 && side == 0 && !copy2.isEmpty{
            for seg in copy1 {
                seg.getSegment().removeFromParent()
            }
            print("copy2")
            for seg in copy2 {
                print(seg.getSegment().position)
                scene.addChild(seg.getSegment())
            }
            currentView = .c2
        } else if currentView == .c2 {
            for seg in copy2 {
                seg.getSegment().removeFromParent()
            }
            if side == 0 && !copy3.isEmpty{
                for seg in copy3 {
                    scene.addChild(seg.getSegment())
                }
                currentView = .c3
            } else if side == 1 {
                for seg in copy1 {
                    scene.addChild(seg.getSegment())
                }
                currentView = .c1
            }
        } else if currentView == .c3 && side == 1 {
            for seg in copy3 {
                seg.getSegment().removeFromParent()
            }
            for seg in copy2 {
                scene.addChild(seg.getSegment())
            }
            currentView = .c2
        }
    }
    
    func getActiveCopy() -> [Segment]{
        if currentView == .c1 {
            return copy1
        } else if currentView == .c2 {
            return copy2
        } else {
            return copy3
        }
    }
    
    func getActiveCopyLength() -> Int {
        if currentView == .c1 {
            return copy1.count
        } else if currentView == .c2 {
            return copy2.count
        } else {
            return copy3.count
        }
    }
//
    func getCopiedSegments() -> Segment {
        var active = getActiveCopy()
        let removed = active.removeFirst()
        removed.getSegment().removeFromParent()
        return removed
    }
    
    func hide(which: [Segment]) {
        
    }
    
    func clearAll() {
        for copy in copies {
            for segment in copy {
                segment.getSegment().removeFromParent()
            }
        }
    }
}
