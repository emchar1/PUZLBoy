//
//  FIRManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/22/22.
//

import Firebase

struct FIRManager {
    static func initializeRecords(completion: (([LevelModel]) -> ())?) {
        var allLevels: [LevelModel] = []
        
        let ref = Database.database().reference()
        ref.observe(DataEventType.value) { snapshot in
            for itemSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                guard let obj = itemSnapshot.value as? [String : AnyObject] else { break }
                
                let levelModel = LevelModel(
                    level: obj["level"] as! Int,
                    moves: obj["moves"] as! Int,
                    
                    //TERRAIN
                    r0c0: obj["r0c0"] as! String,
                    r0c1: obj["r0c1"] as! String,
                    r0c2: obj["r0c2"] as! String,
                    r0c3: obj["r0c3"] as! String,
                    r0c4: obj["r0c4"] as! String,
                    r0c5: obj["r0c5"] as! String,
                    
                    r1c0: obj["r1c0"] as! String,
                    r1c1: obj["r1c1"] as! String,
                    r1c2: obj["r1c2"] as! String,
                    r1c3: obj["r1c3"] as! String,
                    r1c4: obj["r1c4"] as! String,
                    r1c5: obj["r1c5"] as! String,
                    
                    r2c0: obj["r2c0"] as! String,
                    r2c1: obj["r2c1"] as! String,
                    r2c2: obj["r2c2"] as! String,
                    r2c3: obj["r2c3"] as! String,
                    r2c4: obj["r2c4"] as! String,
                    r2c5: obj["r2c5"] as! String,
                    
                    r3c0: obj["r3c0"] as! String,
                    r3c1: obj["r3c1"] as! String,
                    r3c2: obj["r3c2"] as! String,
                    r3c3: obj["r3c3"] as! String,
                    r3c4: obj["r3c4"] as! String,
                    r3c5: obj["r3c5"] as! String,
                    
                    r4c0: obj["r4c0"] as! String,
                    r4c1: obj["r4c1"] as! String,
                    r4c2: obj["r4c2"] as! String,
                    r4c3: obj["r4c3"] as! String,
                    r4c4: obj["r4c4"] as! String,
                    r4c5: obj["r4c5"] as! String,
                    
                    r5c0: obj["r5c0"] as! String,
                    r5c1: obj["r5c1"] as! String,
                    r5c2: obj["r5c2"] as! String,
                    r5c3: obj["r5c3"] as! String,
                    r5c4: obj["r5c4"] as! String,
                    r5c5: obj["r5c5"] as! String,
                    
                    //OVERLAYS
                    s0d0: obj["s0d0"] as! String,
                    s0d1: obj["s0d1"] as! String,
                    s0d2: obj["s0d2"] as! String,
                    s0d3: obj["s0d3"] as! String,
                    s0d4: obj["s0d4"] as! String,
                    s0d5: obj["s0d5"] as! String,
                    
                    s1d0: obj["s1d0"] as! String,
                    s1d1: obj["s1d1"] as! String,
                    s1d2: obj["s1d2"] as! String,
                    s1d3: obj["s1d3"] as! String,
                    s1d4: obj["s1d4"] as! String,
                    s1d5: obj["s1d5"] as! String,
                    
                    s2d0: obj["s2d0"] as! String,
                    s2d1: obj["s2d1"] as! String,
                    s2d2: obj["s2d2"] as! String,
                    s2d3: obj["s2d3"] as! String,
                    s2d4: obj["s2d4"] as! String,
                    s2d5: obj["s2d5"] as! String,
                    
                    s3d0: obj["s3d0"] as! String,
                    s3d1: obj["s3d1"] as! String,
                    s3d2: obj["s3d2"] as! String,
                    s3d3: obj["s3d3"] as! String,
                    s3d4: obj["s3d4"] as! String,
                    s3d5: obj["s3d5"] as! String,
                    
                    s4d0: obj["s4d0"] as! String,
                    s4d1: obj["s4d1"] as! String,
                    s4d2: obj["s4d2"] as! String,
                    s4d3: obj["s4d3"] as! String,
                    s4d4: obj["s4d4"] as! String,
                    s4d5: obj["s4d5"] as! String,
                    
                    s5d0: obj["s5d0"] as! String,
                    s5d1: obj["s5d1"] as! String,
                    s5d2: obj["s5d2"] as! String,
                    s5d3: obj["s5d3"] as! String,
                    s5d4: obj["s5d4"] as! String,
                    s5d5: obj["s5d5"] as! String
                )//end item = LevelModel()
                
                allLevels.append(levelModel)
            }//end for itemSnapshot...
            
            completion?(allLevels)

            //MUST remove observer after downloading once. Is this the best way to do it, right after downloading?
            ref.removeAllObservers()
        }//end ref.observe()
    }//end initializeRecords()
    
}
