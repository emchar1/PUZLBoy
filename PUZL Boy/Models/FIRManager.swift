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
                    r5c5: obj["r5c5"] as! String
                )//end item = LevelModel()
                
                allLevels.append(levelModel)
            }//end for itemSnapshot...
            
            completion?(allLevels)
        }//end ref.observe()
    }//end initializeRecords()
    
}
