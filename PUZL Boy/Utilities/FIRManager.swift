//
//  FIRManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/22/22.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

struct FIRManager {
    ///Only call this once, otherwise App will crash. Also must call it before calling FIRManager.initializeLevelRealtimeRecords().
    static var enableDBPersistence: Void {
        let db = Database.database()
        db.isPersistenceEnabled = true
    }
    
    
    ///Initializes the realtime database and returns all the levels in the rtdb in the completion handler.
    static func initializeLevelRealtimeRecords(completion: (([LevelModel]) -> Void)?) {
        var allLevels: [LevelModel] = []

        let ref = Database.database().reference()
        ref.observe(DataEventType.value) { snapshot in
            for itemSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                guard let obj = itemSnapshot.value as? [String : AnyObject] else { break }
                
                allLevels.append(getLevelModel(from: obj))
            }//end for itemSnapshot...
            
            completion?(allLevels)
            allLevels.removeAll()

            //MUST remove observer after downloading once. Is this the best way to do it, right after downloading?
//            ref.removeAllObservers()
        }//end ref.observe()
    }//end initializeLevelRealtimeRecords()
    
    
    ///Initializes the Firestore database and obtains the documentID that matches the user's UID. Returns nil if document is not found.
    static func initializeSaveStateFirestoreRecords(user: User?, completion: ((SaveStateModel?) -> Void)?) {
        guard let user = user else {
            completion?(nil)
            print("User not signed in. Unable to load Firestore savedState.")
            return
        }
        
        let docRef = Firestore.firestore().collection("savedStates").document(user.uid)
        docRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, let data = snapshot.data() else {
                completion?(nil)
                return
            }
            
            guard let saveDate = data["saveDate"] as? Timestamp,
                  let elapsedTime = data["elapsedTime"] as? TimeInterval,
                  let livesRemaining = data["livesRemaining"] as? Int,
                  let usedContinue = data["usedContinue"] as? Bool,
                  let score = data["score"] as? Int,
                  let totalScore = data["totalScore"] as? Int,
                  let gemsRemaining = data["gemsRemaining"] as? Int,
                  let gemsCollected = data["gemsCollected"] as? Int,
                  let winStreak = data["winStreak"] as? Int,
                  let inventory = data["inventory"] as? [String : AnyObject],
                  let playerPosition = data["playerPosition"] as? [String : AnyObject],
                  let levelModel = data["levelModel"] as? [String : AnyObject],
                  let newLevel = data["newLevel"] as? Int,
                  let uid = data["uid"] as? String else {
                completion?(nil)
                return
            }
            
            let inventoryData = Inventory(hammers: inventory["hammers"] as? Int ?? 0, swords: inventory["swords"] as? Int ?? 0)
            let playerPositionData = PlayerPosition(row: playerPosition["row"] as? Int ?? 0, col: playerPosition["col"] as? Int ?? 0)
            
            completion?(SaveStateModel(saveDate: saveDate.dateValue(),
                                       elapsedTime: elapsedTime,
                                       livesRemaining: livesRemaining,
                                       usedContinue: usedContinue,
                                       score: score,
                                       totalScore: totalScore,
                                       gemsRemaining: gemsRemaining,
                                       gemsCollected: gemsCollected,
                                       winStreak: winStreak,
                                       inventory: inventoryData,
                                       playerPosition: playerPositionData,
                                       levelModel: getLevelModel(from: levelModel),
                                       newLevel: newLevel,
                                       uid: uid))
        }//end docRef.getDocument...
    }//end initializeSaveStateFirestoreRecords()
    
    
    ///Writes to the Firestore Record a.) if it exists, simply overwrite values, b.) if not, create and save the new record.
    static func writeToFirestoreRecord(user: User?, saveStateModel: SaveStateModel?) {
        guard let user = user, let saveStateModel = saveStateModel else {
            print("User not signed in. Unable to load Firestore savedState.")
            return
        }
        
        let docRef = Firestore.firestore().collection("savedStates").document(user.uid)
        docRef.setData([
            "saveDate": Timestamp(date: saveStateModel.saveDate),
            "elapsedTime": saveStateModel.elapsedTime,
            "livesRemaining": saveStateModel.livesRemaining,
            "usedContinue": saveStateModel.usedContinue,
            "score": saveStateModel.score,
            "totalScore": saveStateModel.totalScore,
            "gemsRemaining": saveStateModel.gemsRemaining,
            "gemsCollected": saveStateModel.gemsCollected,
            "winStreak": saveStateModel.winStreak,
            "inventory": [
                "hammers": saveStateModel.inventory.hammers,
                "swords": saveStateModel.inventory.swords
            ],
            "playerPosition": [
                "row": saveStateModel.playerPosition.row,
                "col": saveStateModel.playerPosition.col
            ],
            "levelModel": [
                "level": saveStateModel.levelModel.level,
                "moves": saveStateModel.levelModel.moves,
                "health": saveStateModel.levelModel.health,

                //terrain
                "r0c0": saveStateModel.levelModel.r0c0,
                "r0c1": saveStateModel.levelModel.r0c1,
                "r0c2": saveStateModel.levelModel.r0c2,
                "r0c3": saveStateModel.levelModel.r0c3,
                "r0c4": saveStateModel.levelModel.r0c4,
                "r0c5": saveStateModel.levelModel.r0c5,

                "r1c0": saveStateModel.levelModel.r1c0,
                "r1c1": saveStateModel.levelModel.r1c1,
                "r1c2": saveStateModel.levelModel.r1c2,
                "r1c3": saveStateModel.levelModel.r1c3,
                "r1c4": saveStateModel.levelModel.r1c4,
                "r1c5": saveStateModel.levelModel.r1c5,

                "r2c0": saveStateModel.levelModel.r2c0,
                "r2c1": saveStateModel.levelModel.r2c1,
                "r2c2": saveStateModel.levelModel.r2c2,
                "r2c3": saveStateModel.levelModel.r2c3,
                "r2c4": saveStateModel.levelModel.r2c4,
                "r2c5": saveStateModel.levelModel.r2c5,

                "r3c0": saveStateModel.levelModel.r3c0,
                "r3c1": saveStateModel.levelModel.r3c1,
                "r3c2": saveStateModel.levelModel.r3c2,
                "r3c3": saveStateModel.levelModel.r3c3,
                "r3c4": saveStateModel.levelModel.r3c4,
                "r3c5": saveStateModel.levelModel.r3c5,
                
                "r4c0": saveStateModel.levelModel.r4c0,
                "r4c1": saveStateModel.levelModel.r4c1,
                "r4c2": saveStateModel.levelModel.r4c2,
                "r4c3": saveStateModel.levelModel.r4c3,
                "r4c4": saveStateModel.levelModel.r4c4,
                "r4c5": saveStateModel.levelModel.r4c5,
                
                "r5c0": saveStateModel.levelModel.r5c0,
                "r5c1": saveStateModel.levelModel.r5c1,
                "r5c2": saveStateModel.levelModel.r5c2,
                "r5c3": saveStateModel.levelModel.r5c3,
                "r5c4": saveStateModel.levelModel.r5c4,
                "r5c5": saveStateModel.levelModel.r5c5,

                //overlay
                "s0d0": saveStateModel.levelModel.s0d0,
                "s0d1": saveStateModel.levelModel.s0d1,
                "s0d2": saveStateModel.levelModel.s0d2,
                "s0d3": saveStateModel.levelModel.s0d3,
                "s0d4": saveStateModel.levelModel.s0d4,
                "s0d5": saveStateModel.levelModel.s0d5,

                "s1d0": saveStateModel.levelModel.s1d0,
                "s1d1": saveStateModel.levelModel.s1d1,
                "s1d2": saveStateModel.levelModel.s1d2,
                "s1d3": saveStateModel.levelModel.s1d3,
                "s1d4": saveStateModel.levelModel.s1d4,
                "s1d5": saveStateModel.levelModel.s1d5,

                "s2d0": saveStateModel.levelModel.s2d0,
                "s2d1": saveStateModel.levelModel.s2d1,
                "s2d2": saveStateModel.levelModel.s2d2,
                "s2d3": saveStateModel.levelModel.s2d3,
                "s2d4": saveStateModel.levelModel.s2d4,
                "s2d5": saveStateModel.levelModel.s2d5,

                "s3d0": saveStateModel.levelModel.s3d0,
                "s3d1": saveStateModel.levelModel.s3d1,
                "s3d2": saveStateModel.levelModel.s3d2,
                "s3d3": saveStateModel.levelModel.s3d3,
                "s3d4": saveStateModel.levelModel.s3d4,
                "s3d5": saveStateModel.levelModel.s3d5,
                
                "s4d0": saveStateModel.levelModel.s4d0,
                "s4d1": saveStateModel.levelModel.s4d1,
                "s4d2": saveStateModel.levelModel.s4d2,
                "s4d3": saveStateModel.levelModel.s4d3,
                "s4d4": saveStateModel.levelModel.s4d4,
                "s4d5": saveStateModel.levelModel.s4d5,
                
                "s5d0": saveStateModel.levelModel.s5d0,
                "s5d1": saveStateModel.levelModel.s5d1,
                "s5d2": saveStateModel.levelModel.s5d2,
                "s5d3": saveStateModel.levelModel.s5d3,
                "s5d4": saveStateModel.levelModel.s5d4,
                "s5d5": saveStateModel.levelModel.s5d5
            ],
            "newLevel": saveStateModel.newLevel,
            "uid": saveStateModel.uid
        ])
    }//end writeToFirestoreRecord()
    
    
    ///Helper function to create a levelModel from Firestore object
    private static func getLevelModel(from obj: [String : AnyObject]) -> LevelModel {
        //If obj is bogus, then basically recreate level 1, but make it off by 1 gem (for debugging purposes)
        let levelModel = LevelModel(
            level: obj["level"] as? Int ?? 1,
            moves: obj["moves"] as? Int ?? 4,
            health: obj["health"] as? Int ?? 1,
            
            //TERRAIN
            r0c0: obj["r0c0"] as? String ?? "start",
            r0c1: obj["r0c1"] as? String ?? "grass",
            r0c2: obj["r0c2"] as? String ?? "grass",
            r0c3: obj["r0c3"] as? String ?? "",
            r0c4: obj["r0c4"] as? String ?? "",
            r0c5: obj["r0c5"] as? String ?? "",
            
            r1c0: obj["r1c0"] as? String ?? "grass",
            r1c1: obj["r1c1"] as? String ?? "grass",
            r1c2: obj["r1c2"] as? String ?? "grass",
            r1c3: obj["r1c3"] as? String ?? "",
            r1c4: obj["r1c4"] as? String ?? "",
            r1c5: obj["r1c5"] as? String ?? "",
            
            r2c0: obj["r2c0"] as? String ?? "grass",
            r2c1: obj["r2c1"] as? String ?? "grass",
            r2c2: obj["r2c2"] as? String ?? "endClosed",
            r2c3: obj["r2c3"] as? String ?? "",
            r2c4: obj["r2c4"] as? String ?? "",
            r2c5: obj["r2c5"] as? String ?? "",
            
            r3c0: obj["r3c0"] as? String ?? "",
            r3c1: obj["r3c1"] as? String ?? "",
            r3c2: obj["r3c2"] as? String ?? "",
            r3c3: obj["r3c3"] as? String ?? "",
            r3c4: obj["r3c4"] as? String ?? "",
            r3c5: obj["r3c5"] as? String ?? "",
            
            r4c0: obj["r4c0"] as? String ?? "",
            r4c1: obj["r4c1"] as? String ?? "",
            r4c2: obj["r4c2"] as? String ?? "",
            r4c3: obj["r4c3"] as? String ?? "",
            r4c4: obj["r4c4"] as? String ?? "",
            r4c5: obj["r4c5"] as? String ?? "",
            
            r5c0: obj["r5c0"] as? String ?? "",
            r5c1: obj["r5c1"] as? String ?? "",
            r5c2: obj["r5c2"] as? String ?? "",
            r5c3: obj["r5c3"] as? String ?? "",
            r5c4: obj["r5c4"] as? String ?? "",
            r5c5: obj["r5c5"] as? String ?? "",
            
            //OVERLAYS
            s0d0: obj["s0d0"] as? String ?? "",
            s0d1: obj["s0d1"] as? String ?? "gem",
            s0d2: obj["s0d2"] as? String ?? "",
            s0d3: obj["s0d3"] as? String ?? "",
            s0d4: obj["s0d4"] as? String ?? "",
            s0d5: obj["s0d5"] as? String ?? "",
            
            s1d0: obj["s1d0"] as? String ?? "",
            s1d1: obj["s1d1"] as? String ?? "",
            s1d2: obj["s1d2"] as? String ?? "",
            s1d3: obj["s1d3"] as? String ?? "",
            s1d4: obj["s1d4"] as? String ?? "",
            s1d5: obj["s1d5"] as? String ?? "",
            
            s2d0: obj["s2d0"] as? String ?? "",
            s2d1: obj["s2d1"] as? String ?? "",
            s2d2: obj["s2d2"] as? String ?? "",
            s2d3: obj["s2d3"] as? String ?? "",
            s2d4: obj["s2d4"] as? String ?? "",
            s2d5: obj["s2d5"] as? String ?? "",
            
            s3d0: obj["s3d0"] as? String ?? "",
            s3d1: obj["s3d1"] as? String ?? "",
            s3d2: obj["s3d2"] as? String ?? "",
            s3d3: obj["s3d3"] as? String ?? "",
            s3d4: obj["s3d4"] as? String ?? "",
            s3d5: obj["s3d5"] as? String ?? "",
            
            s4d0: obj["s4d0"] as? String ?? "",
            s4d1: obj["s4d1"] as? String ?? "",
            s4d2: obj["s4d2"] as? String ?? "",
            s4d3: obj["s4d3"] as? String ?? "",
            s4d4: obj["s4d4"] as? String ?? "",
            s4d5: obj["s4d5"] as? String ?? "",
            
            s5d0: obj["s5d0"] as? String ?? "",
            s5d1: obj["s5d1"] as? String ?? "",
            s5d2: obj["s5d2"] as? String ?? "",
            s5d3: obj["s5d3"] as? String ?? "",
            s5d4: obj["s5d4"] as? String ?? "",
            s5d5: obj["s5d5"] as? String ?? ""
        )
        
        return levelModel
    }
}
