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
    
    // MARK: - Properties
    
    ///Only call this once, otherwise App will crash. Also must call it before calling FIRManager.initializeLevelRealtimeRecords().
    static var enableDBPersistence: Void {
        let db = Database.database()
        db.isPersistenceEnabled = true
    }
    
    enum FirestoreError: Error {
        case userNotSignedIn, saveStateNotFound, funnyQuotesNotFound
    }
    
    
    // MARK: - Functions
    
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

            //IMPORTANT!! - If you remove all observers, it won't listen for level updates in real time; it'll only update sporadically, when? I'm not sure. Leave this commented out for now... 6/2/23
//            ref.removeAllObservers()

            print("Realtime database initialized.......")
        }//end ref.observe()
    }//end initializeLevelRealtimeRecords()
    
    ///Convenience initializer for Firestore that loads all the collections, and returns them. How about that?!
    static func initializeFirestore(user: User?, completion: ((SaveStateModel?, FirestoreError?) -> Void)?) {
        guard let user = user else {
            print("Error initializing Firestore: User not signed in.")
            completion?(nil, .userNotSignedIn)
            return
        }
        
        initializeSaveStateFirestoreRecords(user: user) { saveStateModel, saveStateError in
            guard saveStateError == nil, let saveStateModel = saveStateModel else {
                print("Error finding saveState: \(saveStateError!)")
                completion?(nil, .saveStateNotFound)
                return
            }
            
            initializeFunnyQuotes { loadingScreenQuotes, notificationItemQuotes, funnyQuotesError in
                guard funnyQuotesError == nil, let loadingScreenQuotes = loadingScreenQuotes, let notificationItemQuotes = notificationItemQuotes else {
                    print("Firestore saveState initialized, however there was an error populating funnyQuotes: \(funnyQuotesError!)")
                    completion?(saveStateModel, .funnyQuotesNotFound)
                    return
                }
                
                LoadingSprite.funnyQuotes = loadingScreenQuotes
                LifeSpawnerModel.funnyQuotes = notificationItemQuotes
                
                //This is the ultimate success, meaning saveState and funnyQuotes all exist, and the user is signed in!
                completion?(saveStateModel, nil)

                print("Firestore initialized successfully!")
            }
        }
    }
    
    ///Initializes funny quotes arrays
    static func initializeFunnyQuotes(completion: ((_ loadingScreenQuotes: [String]?, _ notificationItemQuotes: [String]?, FirestoreError?) -> Void)?) {
        let collectionRef = Firestore.firestore().collection("funnyQuotes")
        collectionRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot,
                  let loadingScreenDoc = snapshot.documents.filter({ $0.documentID == "loadingScreen" }).first,
                  let notificationItemDoc = snapshot.documents.filter({ $0.documentID == "notificationItem" }).first,
                  let loadingQuotes = loadingScreenDoc.data()["quotes"] as? [String],
                  let notificationQuotes = notificationItemDoc.data()["quotes"] as? [String] else {
                completion?(nil, nil, .funnyQuotesNotFound)
                return
            }

            completion?(loadingQuotes, notificationQuotes, nil)
            
            print("Firestore funny quotes initialized.......")
        }
    }
    
    ///Initializes the Firestore database and obtains the documentID that matches the user's UID. Returns nil if document is not found.
    static func initializeSaveStateFirestoreRecords(user: User?, completion: ((SaveStateModel?, FirestoreError?) -> Void)?) {
        guard let user = user else {
            completion?(nil, .userNotSignedIn)
            return
        }
        
        let docRef = Firestore.firestore().collection("savedStates").document(user.uid)
        docRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, let data = snapshot.data() else {
                completion?(nil, .saveStateNotFound)
                return
            }
            
            guard let saveDate = data["saveDate"] as? Timestamp,
                  let elapsedTime = data["elapsedTime"] as? TimeInterval,
                  let livesRemaining = data["livesRemaining"] as? Int,
                  let usedContinue = data["usedContinue"] as? Bool,
//                  let notFirstTimePlaying = data["notFirstTimePlaying"] as? Bool,
                  let score = data["score"] as? Int,
                  let totalScore = data["totalScore"] as? Int,
                  let winStreak = data["winStreak"] as? Int,
                  let levelStatsArray = data["levelStatsArray"] as? [[String : AnyObject]],
                  let levelModel = data["levelModel"] as? [String : AnyObject],
                  let newLevel = data["newLevel"] as? Int,
                  let uid = data["uid"] as? String else {
                completion?(nil, .saveStateNotFound)
                return
            }
            
            
            completion?(SaveStateModel(saveDate: saveDate.dateValue(),
                                       elapsedTime: elapsedTime,
                                       livesRemaining: livesRemaining,
                                       usedContinue: usedContinue,
//                                       notFirstTimePlaying: notFirstTimePlaying,
                                       score: score,
                                       totalScore: totalScore,
                                       winStreak: winStreak,
                                       levelStatsArray: getLevelStatsArray(from: levelStatsArray),
                                       levelModel: getLevelModel(from: levelModel),
                                       newLevel: newLevel,
                                       uid: uid), nil)
            
            print("Firestore saveState initialized.......")
        }//end docRef.getDocument...
    }//end initializeSaveStateFirestoreRecords()
    
    ///Writes to the Firestore Record a.) if it exists, simply overwrite values, b.) if not, create and save the new record.
    static func writeToFirestoreRecord(user: User?, saveStateModel: SaveStateModel?) {
        guard let user = user, let saveStateModel = saveStateModel else {
            print("User not signed in. Unable to load Firestore savedState.")
            return
        }
        
        var levelStatsArray: [Any] = []
        
        for item in saveStateModel.levelStatsArray {
            levelStatsArray.append([
                "level": item.level,
                "elapsedTime": item.elapsedTime,
                "livesUsed": item.livesUsed,
                "movesRemaining": item.movesRemaining,
                "enemiesKilled": item.enemiesKilled,
                "bouldersBroken": item.bouldersBroken,
                "score": item.score,
                "didWin": item.didWin,
                "inventory": [
                    "hammers": item.inventory.hammers,
                    "swords": item.inventory.swords
                ]
            ] as [String : Any])
        }
        
        let docRef = Firestore.firestore().collection("savedStates").document(user.uid)
        docRef.setData([
            "saveDate": Timestamp(date: saveStateModel.saveDate),
            "elapsedTime": saveStateModel.elapsedTime,
            "livesRemaining": saveStateModel.livesRemaining,
            "usedContinue": saveStateModel.usedContinue,
//            "notFirstTimePlaying": saveStateModel.notFirstTimePlaying,
            "score": saveStateModel.score,
            "totalScore": saveStateModel.totalScore,
            "winStreak": saveStateModel.winStreak,
            "levelStatsArray": levelStatsArray,
            "levelModel": [
                "level": saveStateModel.levelModel.level,
                "moves": saveStateModel.levelModel.moves,
                "health": saveStateModel.levelModel.health,
                "gemsCollected": saveStateModel.levelModel.gemsCollected,
                "gemsRemaining": saveStateModel.levelModel.gemsRemaining,
                "inventory": [
                    "hammers": saveStateModel.levelModel.inventory.hammers,
                    "swords": saveStateModel.levelModel.inventory.swords
                ],
                "playerPosition": [
                    "row": saveStateModel.levelModel.playerPosition.row,
                    "col": saveStateModel.levelModel.playerPosition.col
                ],

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
            ] as [String : Any],
            "newLevel": saveStateModel.newLevel,
            "uid": saveStateModel.uid
        ])
        
        print("Writing to Firestore saveState.......")
    }//end writeToFirestoreRecord()
    
    
    // MARK: - Helper Functions
    
    ///Helper function to create levelStats array from Firestore objects
    private static func getLevelStatsArray(from objects: [[String : AnyObject]]) -> [LevelStats] {
        var levelStatsArray: [LevelStats] = []
        
        for object in objects {
            guard let level = object["level"] as? Int,
                  let elapsedTime = object["elapsedTime"] as? TimeInterval,
                  let livesUsed = object["livesUsed"] as? Int,
                  let movesRemaining = object["movesRemaining"] as? Int,
                  let enemiesKilled = object["enemiesKilled"] as? Int,
                  let bouldersBroken = object["bouldersBroken"] as? Int,
                  let score = object["score"] as? Int,
                  let didWin = object["didWin"] as? Bool,
                  let inventory = object["inventory"] as? [String : AnyObject] else {
                break
            }
            
            let inventoryData = Inventory(hammers: inventory["hammers"] as? Int ?? 0, swords: inventory["swords"] as? Int ?? 0)
            let levelStats = LevelStats(level: level,
                                        elapsedTime: elapsedTime,
                                        livesUsed: livesUsed,
                                        movesRemaining: movesRemaining,
                                        enemiesKilled: enemiesKilled,
                                        bouldersBroken: bouldersBroken,
                                        score: score,
                                        didWin: didWin,
                                        inventory: inventoryData)
            
            levelStatsArray.append(levelStats)
        }
        
        return levelStatsArray
    }
    
    ///Helper function to create a levelModel from Firestore object
    private static func getLevelModel(from object: [String : AnyObject]) -> LevelModel {
        //If obj is bogus, then basically recreate level 1, but make it off by 1 gem (for debugging purposes)
        let playerPosition = object["playerPosition"] as? [String : AnyObject]
        let inventory = object["inventory"] as? [String : AnyObject]
        let levelModel = LevelModel(
            level: object["level"] as? Int ?? 1,
            moves: object["moves"] as? Int ?? 4,
            health: object["health"] as? Int ?? 1,
            gemsCollected: object["gemsCollected"] as? Int ?? 0,
            gemsRemaining: object["gemsRemaining"] as? Int ?? 1,
            playerPosition: PlayerPosition(row: playerPosition?["row"] as? Int ?? 0, col: playerPosition?["col"] as? Int ?? 0),
            inventory: Inventory(hammers: inventory?["hammers"] as? Int ?? 999, swords: inventory?["swords"] as? Int ?? 999),
            
            
            //TERRAIN
            r0c0: object["r0c0"] as? String ?? "start",
            r0c1: object["r0c1"] as? String ?? "grass",
            r0c2: object["r0c2"] as? String ?? "grass",
            r0c3: object["r0c3"] as? String ?? "",
            r0c4: object["r0c4"] as? String ?? "",
            r0c5: object["r0c5"] as? String ?? "",
            
            r1c0: object["r1c0"] as? String ?? "grass",
            r1c1: object["r1c1"] as? String ?? "grass",
            r1c2: object["r1c2"] as? String ?? "grass",
            r1c3: object["r1c3"] as? String ?? "",
            r1c4: object["r1c4"] as? String ?? "",
            r1c5: object["r1c5"] as? String ?? "",
            
            r2c0: object["r2c0"] as? String ?? "grass",
            r2c1: object["r2c1"] as? String ?? "grass",
            r2c2: object["r2c2"] as? String ?? "endClosed",
            r2c3: object["r2c3"] as? String ?? "",
            r2c4: object["r2c4"] as? String ?? "",
            r2c5: object["r2c5"] as? String ?? "",
            
            r3c0: object["r3c0"] as? String ?? "",
            r3c1: object["r3c1"] as? String ?? "",
            r3c2: object["r3c2"] as? String ?? "",
            r3c3: object["r3c3"] as? String ?? "",
            r3c4: object["r3c4"] as? String ?? "",
            r3c5: object["r3c5"] as? String ?? "",
            
            r4c0: object["r4c0"] as? String ?? "",
            r4c1: object["r4c1"] as? String ?? "",
            r4c2: object["r4c2"] as? String ?? "",
            r4c3: object["r4c3"] as? String ?? "",
            r4c4: object["r4c4"] as? String ?? "",
            r4c5: object["r4c5"] as? String ?? "",
            
            r5c0: object["r5c0"] as? String ?? "",
            r5c1: object["r5c1"] as? String ?? "",
            r5c2: object["r5c2"] as? String ?? "",
            r5c3: object["r5c3"] as? String ?? "",
            r5c4: object["r5c4"] as? String ?? "",
            r5c5: object["r5c5"] as? String ?? "",
            
            //OVERLAYS
            s0d0: object["s0d0"] as? String ?? "",
            s0d1: object["s0d1"] as? String ?? "gem",
            s0d2: object["s0d2"] as? String ?? "",
            s0d3: object["s0d3"] as? String ?? "",
            s0d4: object["s0d4"] as? String ?? "",
            s0d5: object["s0d5"] as? String ?? "",
            
            s1d0: object["s1d0"] as? String ?? "",
            s1d1: object["s1d1"] as? String ?? "",
            s1d2: object["s1d2"] as? String ?? "",
            s1d3: object["s1d3"] as? String ?? "",
            s1d4: object["s1d4"] as? String ?? "",
            s1d5: object["s1d5"] as? String ?? "",
            
            s2d0: object["s2d0"] as? String ?? "",
            s2d1: object["s2d1"] as? String ?? "",
            s2d2: object["s2d2"] as? String ?? "",
            s2d3: object["s2d3"] as? String ?? "",
            s2d4: object["s2d4"] as? String ?? "",
            s2d5: object["s2d5"] as? String ?? "",
            
            s3d0: object["s3d0"] as? String ?? "",
            s3d1: object["s3d1"] as? String ?? "",
            s3d2: object["s3d2"] as? String ?? "",
            s3d3: object["s3d3"] as? String ?? "",
            s3d4: object["s3d4"] as? String ?? "",
            s3d5: object["s3d5"] as? String ?? "",
            
            s4d0: object["s4d0"] as? String ?? "",
            s4d1: object["s4d1"] as? String ?? "",
            s4d2: object["s4d2"] as? String ?? "",
            s4d3: object["s4d3"] as? String ?? "",
            s4d4: object["s4d4"] as? String ?? "",
            s4d5: object["s4d5"] as? String ?? "",
            
            s5d0: object["s5d0"] as? String ?? "",
            s5d1: object["s5d1"] as? String ?? "",
            s5d2: object["s5d2"] as? String ?? "",
            s5d3: object["s5d3"] as? String ?? "",
            s5d4: object["s5d4"] as? String ?? "",
            s5d5: object["s5d5"] as? String ?? ""
        )
        
        return levelModel
    }
}
