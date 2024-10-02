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
    
    static var user: User?
    static var saveStateModel: SaveStateModel?

    //Age of Ruin Properties
    static var bravery: Int?
    static var decisionsLeftButton: [Bool?] = [nil, nil, nil, nil]
    static var hasFeather: Bool?
    static var gotGift: Bool?
    
    static var didGiveAwayFeather: Bool {
        decisionsLeftButton[2] != nil && decisionsLeftButton[2]!
    }
    
    static var didReceiveGiftFromTiki: Bool {
        gotGift ?? false
    }
    
    //Test users
    static let userEddie = "2bjhz2grYVVOn37qmUipG4CKps62"
    static let userMichel = "NB9OLr2X8kRLJ7S0G8W3800qo8U2"
    static let userMom = "jnsBD8RFVDMN9cSN8yDnFDoVJp32"
    
    ///Only call this once, otherwise App will crash. Also must call it before calling FIRManager.initializeLevelRealtimeRecords().
    static var enableDBPersistence: Void {
        let db = Database.database()
        db.isPersistenceEnabled = true
    }

    ///Returns the Firestore user's UID, first by checking Firestore (server), then UserDefaults (local), and finally nil if neither exists
    static var uid: String? {
        return user?.uid ?? UserDefaults.standard.string(forKey: K.UserDefaults.firebaseUID)
    }

    enum FirestoreError: Error {
        case isNewUser, saveStateNotFound, funnyQuotesNotFound
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
    static func initializeFirestore(completion: ((SaveStateModel?, FirestoreError?) -> Void)?) {
        initializeSaveStateFirestoreRecords() { saveStateModel, saveStateError in
            guard saveStateError == nil, let saveStateModel = saveStateModel else {
                print("Error finding saveState: \(saveStateError!)")
                completion?(nil, .saveStateNotFound)
                return
            }
            
            self.saveStateModel = saveStateModel
            
            initializeFunnyQuotes { loadingScreenQuotes, notificationItemQuotes, songLyricsQuotes, hero251Quote, funnyQuotesError in
                guard funnyQuotesError == nil,
                      let loadingScreenQuotes = loadingScreenQuotes,
                      let notificationItemQuotes = notificationItemQuotes,
                      let songLyricsQuotes = songLyricsQuotes,
                      let hero251Quote = hero251Quote else {
                    print("Firestore saveState initialized, however there was an error populating funnyQuotes: \(funnyQuotesError!)")
                    completion?(saveStateModel, .funnyQuotesNotFound)
                    return
                }
                
                LoadingSprite.funnyQuotes = loadingScreenQuotes
                LifeSpawnerModel.funnyQuotes = notificationItemQuotes
                CutsceneIntro.funnyQuotes = songLyricsQuotes
                ChatEngine.hero251Quote = hero251Quote
                
                //This is the ultimate success, meaning saveState and funnyQuotes all exist, and the user is signed in!
                completion?(saveStateModel, nil)

                print("Firestore initialized successfully!")
            }
        }
    }
    
    ///Initializes funny quotes arrays and string. It's all or nothing; if one fails, they all fail and return all nils.
    static func initializeFunnyQuotes(completion: ((_ loadingScreenQuotes: [String]?, 
                                                    _ notificationItemQuotes: [String]?,
                                                    _ songLyricsQuotes: [String]?,
                                                    _ hero251: String?,
                                                    FirestoreError?) -> Void)?) {
        let collectionRef = Firestore.firestore().collection("funnyQuotes")
        collectionRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot,
                  let loadingScreenDoc = snapshot.documents.filter({ $0.documentID == "loadingScreen" }).first,
                  let notificationItemDoc = snapshot.documents.filter({ $0.documentID == "notificationItem" }).first,
                  let songLyricsDoc = snapshot.documents.filter({ $0.documentID == "songLyrics" }).first,
                  let hero251Doc = snapshot.documents.filter({ $0.documentID == "hero251" }).first,
                  let loadingQuotes = loadingScreenDoc.data()["quotes"] as? [String],
                  let notificationQuotes = notificationItemDoc.data()["quotes"] as? [String],
                  let lyricsQuotes = songLyricsDoc.data()["quotes"] as? [String],
                  let hero251Quote = hero251Doc.data()["chatDialogue"] as? String else {
                completion?(nil, nil, nil, nil, .funnyQuotesNotFound)
                return
            }

            completion?(loadingQuotes, notificationQuotes, lyricsQuotes, hero251Quote, nil)
            
            print("Firestore funny quotes initialized.......")
        }
    }
    
    ///Initializes the Firestore database and obtains the documentID that matches the user's UID.
    private static func initializeSaveStateFirestoreRecords(completion: ((SaveStateModel?, FirestoreError?) -> Void)?) {
        guard let uid = uid else {
            completion?(nil, .isNewUser)
            return
        }
        
        let docRef = Firestore.firestore().collection("savedStates").document(uid)
        docRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, let data = snapshot.data() else {
                completion?(nil, .saveStateNotFound)
                return
            }
            
            guard let ageOfRuin = data["aorAgeOfRuin"] as? Bool,
                  let elapsedTime = data["elapsedTime"] as? TimeInterval,
                  let gameCompleted = data["gameCompleted"] as? Bool,
                  let hintAvailable = data["hintAvailable"] as? Bool,
                  let hintCountRemaining = data["hintCountRemaining"] as? Int,
                  let levelModel = data["levelModel"] as? [String : AnyObject],
                  let levelStatsArray = data["levelStatsArray"] as? [[String : AnyObject]],
                  let livesRemaining = data["livesRemaining"] as? Int,
                  let newLevel = data["newLevel"] as? Int,
                  let saveDate = data["saveDate"] as? Timestamp,
                  let score = data["score"] as? Int,
                  let totalScore = data["totalScore"] as? Int,
                  let uid = data["uid"] as? String,
                  let usedContinue = data["usedContinue"] as? Bool,
                  let winStreak = data["winStreak"] as? Int else {
                completion?(nil, .saveStateNotFound)
                return
            }
            
            for i in 0...3 {
                decisionsLeftButton[i] = data["aorDecisionLeftButton\(i)"] as? Bool
            }
            
            bravery = data["aorBravery"] as? Int
            hasFeather = data["aorHasFeather"] as? Bool
            gotGift = data["aorGotGift"] as? Bool
            
            completion?(SaveStateModel(aorAgeOfRuin: ageOfRuin,
                                       aorBravery: bravery,
                                       aorDecisionLeftButton0: decisionsLeftButton[0],
                                       aorDecisionLeftButton1: decisionsLeftButton[1],
                                       aorDecisionLeftButton2: decisionsLeftButton[2],
                                       aorDecisionLeftButton3: decisionsLeftButton[3],
                                       aorHasFeather: hasFeather,
                                       aorGotGift: gotGift,
                                       elapsedTime: elapsedTime,
                                       gameCompleted: gameCompleted,
                                       hintAvailable: hintAvailable,
                                       hintCountRemaining: hintCountRemaining,
                                       levelModel: getLevelModel(from: levelModel),
                                       levelStatsArray: getLevelStatsArray(from: levelStatsArray),
                                       livesRemaining: livesRemaining,
                                       newLevel: newLevel,
                                       saveDate: saveDate.dateValue(),
                                       score: score,
                                       totalScore: totalScore,
                                       uid: uid,
                                       usedContinue: usedContinue,
                                       winStreak: winStreak), nil)
            
            print("Firestore saveState initialized.......")
        }//end docRef.getDocument...
    }//end initializeSaveStateFirestoreRecords()
    
    ///Writes to the Firestore Record a.) if it exists, simply overwrite values, b.) if not, create and save the new record.
    static func writeToFirestoreRecord(saveStateModel: SaveStateModel?) {
        guard let uid = uid else {
            print("New Firestore user.")
            return
        }
        
        guard let saveStateModel = saveStateModel else {
            print("Unable to load Firestore savedState.")
            return
        }
        
        self.saveStateModel = saveStateModel
        
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
        
        let docRef = Firestore.firestore().collection("savedStates").document(uid)
        docRef.setData([
            "aorAgeOfRuin": saveStateModel.aorAgeOfRuin,
            "aorBravery": bravery as Any, //use static property, instead of saveStateModel
            "aorDecisionLeftButton0": decisionsLeftButton[0] as Any, //use static property, instead of saveStateModel
            "aorDecisionLeftButton1": decisionsLeftButton[1] as Any, //use static property, instead of saveStateModel
            "aorDecisionLeftButton2": decisionsLeftButton[2] as Any, //use static property, instead of saveStateModel
            "aorDecisionLeftButton3": decisionsLeftButton[3] as Any, //use static property, instead of saveStateModel
            "aorHasFeather": hasFeather as Any, //use the static property, instead of saveStateModel (which will give you the old one)
            "aorGotGift": gotGift as Any, //use the static property, instead of saveStateModel
            "elapsedTime": saveStateModel.elapsedTime,
            "gameCompleted": saveStateModel.gameCompleted,
            "hintAvailable": saveStateModel.hintAvailable,
            "hintCountRemaining": saveStateModel.hintCountRemaining,
            "levelModel": [
                "level": saveStateModel.levelModel.level,
                "moves": saveStateModel.levelModel.moves,
                "health": saveStateModel.levelModel.health,
                "hintsAttempt": saveStateModel.levelModel.hintsAttempt,
                "hintsBought": saveStateModel.levelModel.hintsBought,
                "hintsSolution": saveStateModel.levelModel.hintsSolution,
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
                "r0c6": saveStateModel.levelModel.r0c6,

                "r1c0": saveStateModel.levelModel.r1c0,
                "r1c1": saveStateModel.levelModel.r1c1,
                "r1c2": saveStateModel.levelModel.r1c2,
                "r1c3": saveStateModel.levelModel.r1c3,
                "r1c4": saveStateModel.levelModel.r1c4,
                "r1c5": saveStateModel.levelModel.r1c5,
                "r1c6": saveStateModel.levelModel.r1c6,

                "r2c0": saveStateModel.levelModel.r2c0,
                "r2c1": saveStateModel.levelModel.r2c1,
                "r2c2": saveStateModel.levelModel.r2c2,
                "r2c3": saveStateModel.levelModel.r2c3,
                "r2c4": saveStateModel.levelModel.r2c4,
                "r2c5": saveStateModel.levelModel.r2c5,
                "r2c6": saveStateModel.levelModel.r2c6,

                "r3c0": saveStateModel.levelModel.r3c0,
                "r3c1": saveStateModel.levelModel.r3c1,
                "r3c2": saveStateModel.levelModel.r3c2,
                "r3c3": saveStateModel.levelModel.r3c3,
                "r3c4": saveStateModel.levelModel.r3c4,
                "r3c5": saveStateModel.levelModel.r3c5,
                "r3c6": saveStateModel.levelModel.r3c6,
                
                "r4c0": saveStateModel.levelModel.r4c0,
                "r4c1": saveStateModel.levelModel.r4c1,
                "r4c2": saveStateModel.levelModel.r4c2,
                "r4c3": saveStateModel.levelModel.r4c3,
                "r4c4": saveStateModel.levelModel.r4c4,
                "r4c5": saveStateModel.levelModel.r4c5,
                "r4c6": saveStateModel.levelModel.r4c6,
                
                "r5c0": saveStateModel.levelModel.r5c0,
                "r5c1": saveStateModel.levelModel.r5c1,
                "r5c2": saveStateModel.levelModel.r5c2,
                "r5c3": saveStateModel.levelModel.r5c3,
                "r5c4": saveStateModel.levelModel.r5c4,
                "r5c5": saveStateModel.levelModel.r5c5,
                "r5c6": saveStateModel.levelModel.r5c6,
                
                "r6c0": saveStateModel.levelModel.r6c0,
                "r6c1": saveStateModel.levelModel.r6c1,
                "r6c2": saveStateModel.levelModel.r6c2,
                "r6c3": saveStateModel.levelModel.r6c3,
                "r6c4": saveStateModel.levelModel.r6c4,
                "r6c5": saveStateModel.levelModel.r6c5,
                "r6c6": saveStateModel.levelModel.r6c6,

                //overlay
                "s0d0": saveStateModel.levelModel.s0d0,
                "s0d1": saveStateModel.levelModel.s0d1,
                "s0d2": saveStateModel.levelModel.s0d2,
                "s0d3": saveStateModel.levelModel.s0d3,
                "s0d4": saveStateModel.levelModel.s0d4,
                "s0d5": saveStateModel.levelModel.s0d5,
                "s0d6": saveStateModel.levelModel.s0d6,

                "s1d0": saveStateModel.levelModel.s1d0,
                "s1d1": saveStateModel.levelModel.s1d1,
                "s1d2": saveStateModel.levelModel.s1d2,
                "s1d3": saveStateModel.levelModel.s1d3,
                "s1d4": saveStateModel.levelModel.s1d4,
                "s1d5": saveStateModel.levelModel.s1d5,
                "s1d6": saveStateModel.levelModel.s1d6,

                "s2d0": saveStateModel.levelModel.s2d0,
                "s2d1": saveStateModel.levelModel.s2d1,
                "s2d2": saveStateModel.levelModel.s2d2,
                "s2d3": saveStateModel.levelModel.s2d3,
                "s2d4": saveStateModel.levelModel.s2d4,
                "s2d5": saveStateModel.levelModel.s2d5,
                "s2d6": saveStateModel.levelModel.s2d6,

                "s3d0": saveStateModel.levelModel.s3d0,
                "s3d1": saveStateModel.levelModel.s3d1,
                "s3d2": saveStateModel.levelModel.s3d2,
                "s3d3": saveStateModel.levelModel.s3d3,
                "s3d4": saveStateModel.levelModel.s3d4,
                "s3d5": saveStateModel.levelModel.s3d5,
                "s3d6": saveStateModel.levelModel.s3d6,
                
                "s4d0": saveStateModel.levelModel.s4d0,
                "s4d1": saveStateModel.levelModel.s4d1,
                "s4d2": saveStateModel.levelModel.s4d2,
                "s4d3": saveStateModel.levelModel.s4d3,
                "s4d4": saveStateModel.levelModel.s4d4,
                "s4d5": saveStateModel.levelModel.s4d5,
                "s4d6": saveStateModel.levelModel.s4d6,
                
                "s5d0": saveStateModel.levelModel.s5d0,
                "s5d1": saveStateModel.levelModel.s5d1,
                "s5d2": saveStateModel.levelModel.s5d2,
                "s5d3": saveStateModel.levelModel.s5d3,
                "s5d4": saveStateModel.levelModel.s5d4,
                "s5d5": saveStateModel.levelModel.s5d5,
                "s5d6": saveStateModel.levelModel.s5d6,

                "s6d0": saveStateModel.levelModel.s6d0,
                "s6d1": saveStateModel.levelModel.s6d1,
                "s6d2": saveStateModel.levelModel.s6d2,
                "s6d3": saveStateModel.levelModel.s6d3,
                "s6d4": saveStateModel.levelModel.s6d4,
                "s6d5": saveStateModel.levelModel.s6d5,
                "s6d6": saveStateModel.levelModel.s6d6
            ] as [String : Any],
            "levelStatsArray": levelStatsArray,
            "livesRemaining": saveStateModel.livesRemaining,
            "newLevel": saveStateModel.newLevel,
            "saveDate": Timestamp(date: saveStateModel.saveDate),
            "score": saveStateModel.score,
            "totalScore": saveStateModel.totalScore,
            "uid": saveStateModel.uid,
            "usedContinue": saveStateModel.usedContinue,
            "winStreak": saveStateModel.winStreak
        ])
        
        print("Writing to Firestore saveState.......")
    }//end writeToFirestoreRecord()
    
    ///Updates just certain records in the Firestore db
    static func updateFirestoreRecordFields(fields: [AnyHashable : Any]) {
        guard let uid = uid else {
            print("New Firestore user.")
            return
        }
        
        let docRef = Firestore.firestore().collection("savedStates").document(uid)
        docRef.updateData(fields)
        
        print("Writing to Firestore: \(fields)")
    }
    
    ///Convenience method to update the decision field in a record and the static decisions array property.
    static func updateFirestoreRecordDecision(index: Int, buttonOrder: ChatDecisionEngine.ButtonOrder?) {
        let indexAdjusted = index.clamp(min: 0, max: 3)
        let FIRfield = "aorDecisionLeftButton\(indexAdjusted)"
        let FIRvalue: Bool?
        
        if let buttonOrder = buttonOrder {
            FIRvalue = buttonOrder == .left
        }
        else {
            FIRvalue = nil
        }

        decisionsLeftButton[indexAdjusted] = FIRvalue

        updateFirestoreRecordFields(fields: [FIRfield : FIRvalue ?? NSNull()])
    }

    ///Convenience method to update the bravery field in a record and the static property.
    static func updateFirestoreRecordBravery(_ bravery: Int?) {
        self.bravery = bravery
        updateFirestoreRecordFields(fields: ["aorBravery" : bravery ?? NSNull()])
    }

    ///Convenience method to update the hasFeather field in a record and the static property.
    static func updateFirestoreRecordHasFeather(_ hasFeather: Bool?) {
        self.hasFeather = hasFeather
        updateFirestoreRecordFields(fields: ["aorHasFeather" : hasFeather ?? NSNull()])
    }
    
    ///Convenience method to update the gotGift field in a record and the static property.
    static func updateFirestoreRecordGotGift(_ gotGift: Bool?) {
        self.gotGift = gotGift
        updateFirestoreRecordFields(fields: ["aorGotGift" : gotGift ?? NSNull()])
    }
    
    ///Convenience method to update just the newLevel field in a record.
    static func updateFirestoreRecordNewLevel(newLevel: Int) {
        updateFirestoreRecordFields(fields: ["newLevel" : newLevel])
    }
    
    ///Convenience method to update livesRemaining field in a record.
    static func updateFirestoreRecordLivesRemaining(lives: Int) {
        updateFirestoreRecordFields(fields: ["livesRemaining" : lives])
    }
    
    
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
        let gameboardDict = prepareGameboardDict(from: object)
        
        let levelModel = LevelModel(
            level: object["level"] as? Int ?? 1,
            moves: object["moves"] as? Int ?? 4,
            health: object["health"] as? Int ?? 1,
            hintsAttempt: object["hintsAttempt"] as? String ?? "",
            hintsBought: object["hintsBought"] as? String ?? "",
            hintsSolution: object["hintsSolution"] as? String ?? "",
            gemsCollected: object["gemsCollected"] as? Int ?? 0,
            gemsRemaining: object["gemsRemaining"] as? Int ?? 1,
            playerPosition: PlayerPosition(row: playerPosition?["row"] as? Int ?? 0, col: playerPosition?["col"] as? Int ?? 0),
            inventory: Inventory(hammers: inventory?["hammers"] as? Int ?? 999, swords: inventory?["swords"] as? Int ?? 999),
            
            
            //TERRAIN
            r0c0: gameboardDict["r0c0"]!,
            r0c1: gameboardDict["r0c1"]!,
            r0c2: gameboardDict["r0c2"]!,
            r0c3: gameboardDict["r0c3"]!,
            r0c4: gameboardDict["r0c4"]!,
            r0c5: gameboardDict["r0c5"]!,
            r0c6: gameboardDict["r0c6"]!,

            r1c0: gameboardDict["r1c0"]!,
            r1c1: gameboardDict["r1c1"]!,
            r1c2: gameboardDict["r1c2"]!,
            r1c3: gameboardDict["r1c3"]!,
            r1c4: gameboardDict["r1c4"]!,
            r1c5: gameboardDict["r1c5"]!,
            r1c6: gameboardDict["r1c6"]!,

            r2c0: gameboardDict["r2c0"]!,
            r2c1: gameboardDict["r2c1"]!,
            r2c2: gameboardDict["r2c2"]!,
            r2c3: gameboardDict["r2c3"]!,
            r2c4: gameboardDict["r2c4"]!,
            r2c5: gameboardDict["r2c5"]!,
            r2c6: gameboardDict["r2c6"]!,

            r3c0: gameboardDict["r3c0"]!,
            r3c1: gameboardDict["r3c1"]!,
            r3c2: gameboardDict["r3c2"]!,
            r3c3: gameboardDict["r3c3"]!,
            r3c4: gameboardDict["r3c4"]!,
            r3c5: gameboardDict["r3c5"]!,
            r3c6: gameboardDict["r3c6"]!,

            r4c0: gameboardDict["r4c0"]!,
            r4c1: gameboardDict["r4c1"]!,
            r4c2: gameboardDict["r4c2"]!,
            r4c3: gameboardDict["r4c3"]!,
            r4c4: gameboardDict["r4c4"]!,
            r4c5: gameboardDict["r4c5"]!,
            r4c6: gameboardDict["r4c6"]!,

            r5c0: gameboardDict["r5c0"]!,
            r5c1: gameboardDict["r5c1"]!,
            r5c2: gameboardDict["r5c2"]!,
            r5c3: gameboardDict["r5c3"]!,
            r5c4: gameboardDict["r5c4"]!,
            r5c5: gameboardDict["r5c5"]!,
            r5c6: gameboardDict["r5c6"]!,

            r6c0: gameboardDict["r6c0"]!,
            r6c1: gameboardDict["r6c1"]!,
            r6c2: gameboardDict["r6c2"]!,
            r6c3: gameboardDict["r6c3"]!,
            r6c4: gameboardDict["r6c4"]!,
            r6c5: gameboardDict["r6c5"]!,
            r6c6: gameboardDict["r6c6"]!,

            //OVERLAYS
            s0d0: gameboardDict["s0d0"]!,
            s0d1: gameboardDict["s0d1"]!,
            s0d2: gameboardDict["s0d2"]!,
            s0d3: gameboardDict["s0d3"]!,
            s0d4: gameboardDict["s0d4"]!,
            s0d5: gameboardDict["s0d5"]!,
            s0d6: gameboardDict["s0d6"]!,

            s1d0: gameboardDict["s1d0"]!,
            s1d1: gameboardDict["s1d1"]!,
            s1d2: gameboardDict["s1d2"]!,
            s1d3: gameboardDict["s1d3"]!,
            s1d4: gameboardDict["s1d4"]!,
            s1d5: gameboardDict["s1d5"]!,
            s1d6: gameboardDict["s1d6"]!,

            s2d0: gameboardDict["s2d0"]!,
            s2d1: gameboardDict["s2d1"]!,
            s2d2: gameboardDict["s2d2"]!,
            s2d3: gameboardDict["s2d3"]!,
            s2d4: gameboardDict["s2d4"]!,
            s2d5: gameboardDict["s2d5"]!,
            s2d6: gameboardDict["s2d6"]!,

            s3d0: gameboardDict["s3d0"]!,
            s3d1: gameboardDict["s3d1"]!,
            s3d2: gameboardDict["s3d2"]!,
            s3d3: gameboardDict["s3d3"]!,
            s3d4: gameboardDict["s3d4"]!,
            s3d5: gameboardDict["s3d5"]!,
            s3d6: gameboardDict["s3d6"]!,

            s4d0: gameboardDict["s4d0"]!,
            s4d1: gameboardDict["s4d1"]!,
            s4d2: gameboardDict["s4d2"]!,
            s4d3: gameboardDict["s4d3"]!,
            s4d4: gameboardDict["s4d4"]!,
            s4d5: gameboardDict["s4d5"]!,
            s4d6: gameboardDict["s4d6"]!,

            s5d0: gameboardDict["s5d0"]!,
            s5d1: gameboardDict["s5d1"]!,
            s5d2: gameboardDict["s5d2"]!,
            s5d3: gameboardDict["s5d3"]!,
            s5d4: gameboardDict["s5d4"]!,
            s5d5: gameboardDict["s5d5"]!,
            s5d6: gameboardDict["s5d6"]!,

            s6d0: gameboardDict["s6d0"]!,
            s6d1: gameboardDict["s6d1"]!,
            s6d2: gameboardDict["s6d2"]!,
            s6d3: gameboardDict["s6d3"]!,
            s6d4: gameboardDict["s6d4"]!,
            s6d5: gameboardDict["s6d5"]!,
            s6d6: gameboardDict["s6d6"]!
        )
        
        return levelModel
    }
    
    private static func prepareGameboardDict(from object: [String : AnyObject]) -> [String : String] {
        var levelModelGameboardDict: [String : String] = [:]
        
        //TERRAIN
        levelModelGameboardDict["r0c0"] = object["r0c0"] as? String ?? "start"
        levelModelGameboardDict["r0c1"] = object["r0c1"] as? String ?? "grass"
        levelModelGameboardDict["r0c2"] = object["r0c2"] as? String ?? "grass"
        levelModelGameboardDict["r0c3"] = object["r0c3"] as? String ?? ""
        levelModelGameboardDict["r0c4"] = object["r0c4"] as? String ?? ""
        levelModelGameboardDict["r0c5"] = object["r0c5"] as? String ?? ""
        levelModelGameboardDict["r0c6"] = object["r0c6"] as? String ?? ""

        levelModelGameboardDict["r1c0"] = object["r1c0"] as? String ?? "grass"
        levelModelGameboardDict["r1c1"] = object["r1c1"] as? String ?? "grass"
        levelModelGameboardDict["r1c2"] = object["r1c2"] as? String ?? "grass"
        levelModelGameboardDict["r1c3"] = object["r1c3"] as? String ?? ""
        levelModelGameboardDict["r1c4"] = object["r1c4"] as? String ?? ""
        levelModelGameboardDict["r1c5"] = object["r1c5"] as? String ?? ""
        levelModelGameboardDict["r1c6"] = object["r1c6"] as? String ?? ""

        levelModelGameboardDict["r2c0"] = object["r2c0"] as? String ?? "grass"
        levelModelGameboardDict["r2c1"] = object["r2c1"] as? String ?? "grass"
        levelModelGameboardDict["r2c2"] = object["r2c2"] as? String ?? "endClosed"
        levelModelGameboardDict["r2c3"] = object["r2c3"] as? String ?? ""
        levelModelGameboardDict["r2c4"] = object["r2c4"] as? String ?? ""
        levelModelGameboardDict["r2c5"] = object["r2c5"] as? String ?? ""
        levelModelGameboardDict["r2c6"] = object["r2c6"] as? String ?? ""

        levelModelGameboardDict["r3c0"] = object["r3c0"] as? String ?? ""
        levelModelGameboardDict["r3c1"] = object["r3c1"] as? String ?? ""
        levelModelGameboardDict["r3c2"] = object["r3c2"] as? String ?? ""
        levelModelGameboardDict["r3c3"] = object["r3c3"] as? String ?? ""
        levelModelGameboardDict["r3c4"] = object["r3c4"] as? String ?? ""
        levelModelGameboardDict["r3c5"] = object["r3c5"] as? String ?? ""
        levelModelGameboardDict["r3c6"] = object["r3c6"] as? String ?? ""

        levelModelGameboardDict["r4c0"] = object["r4c0"] as? String ?? ""
        levelModelGameboardDict["r4c1"] = object["r4c1"] as? String ?? ""
        levelModelGameboardDict["r4c2"] = object["r4c2"] as? String ?? ""
        levelModelGameboardDict["r4c3"] = object["r4c3"] as? String ?? ""
        levelModelGameboardDict["r4c4"] = object["r4c4"] as? String ?? ""
        levelModelGameboardDict["r4c5"] = object["r4c5"] as? String ?? ""
        levelModelGameboardDict["r4c6"] = object["r4c6"] as? String ?? ""

        levelModelGameboardDict["r5c0"] = object["r5c0"] as? String ?? ""
        levelModelGameboardDict["r5c1"] = object["r5c1"] as? String ?? ""
        levelModelGameboardDict["r5c2"] = object["r5c2"] as? String ?? ""
        levelModelGameboardDict["r5c3"] = object["r5c3"] as? String ?? ""
        levelModelGameboardDict["r5c4"] = object["r5c4"] as? String ?? ""
        levelModelGameboardDict["r5c5"] = object["r5c5"] as? String ?? ""
        levelModelGameboardDict["r5c6"] = object["r5c6"] as? String ?? ""

        levelModelGameboardDict["r6c0"] = object["r6c0"] as? String ?? ""
        levelModelGameboardDict["r6c1"] = object["r6c1"] as? String ?? ""
        levelModelGameboardDict["r6c2"] = object["r6c2"] as? String ?? ""
        levelModelGameboardDict["r6c3"] = object["r6c3"] as? String ?? ""
        levelModelGameboardDict["r6c4"] = object["r6c4"] as? String ?? ""
        levelModelGameboardDict["r6c5"] = object["r6c5"] as? String ?? ""
        levelModelGameboardDict["r6c6"] = object["r6c6"] as? String ?? ""

        //OVERLAYS
        levelModelGameboardDict["s0d0"] = object["s0d0"] as? String ?? ""
        levelModelGameboardDict["s0d1"] = object["s0d1"] as? String ?? "gem"
        levelModelGameboardDict["s0d2"] = object["s0d2"] as? String ?? ""
        levelModelGameboardDict["s0d3"] = object["s0d3"] as? String ?? ""
        levelModelGameboardDict["s0d4"] = object["s0d4"] as? String ?? ""
        levelModelGameboardDict["s0d5"] = object["s0d5"] as? String ?? ""
        levelModelGameboardDict["s0d6"] = object["s0d6"] as? String ?? ""

        levelModelGameboardDict["s1d0"] = object["s1d0"] as? String ?? ""
        levelModelGameboardDict["s1d1"] = object["s1d1"] as? String ?? ""
        levelModelGameboardDict["s1d2"] = object["s1d2"] as? String ?? ""
        levelModelGameboardDict["s1d3"] = object["s1d3"] as? String ?? ""
        levelModelGameboardDict["s1d4"] = object["s1d4"] as? String ?? ""
        levelModelGameboardDict["s1d5"] = object["s1d5"] as? String ?? ""
        levelModelGameboardDict["s1d6"] = object["s1d6"] as? String ?? ""

        levelModelGameboardDict["s2d0"] = object["s2d0"] as? String ?? ""
        levelModelGameboardDict["s2d1"] = object["s2d1"] as? String ?? ""
        levelModelGameboardDict["s2d2"] = object["s2d2"] as? String ?? ""
        levelModelGameboardDict["s2d3"] = object["s2d3"] as? String ?? ""
        levelModelGameboardDict["s2d4"] = object["s2d4"] as? String ?? ""
        levelModelGameboardDict["s2d5"] = object["s2d5"] as? String ?? ""
        levelModelGameboardDict["s2d6"] = object["s2d6"] as? String ?? ""

        levelModelGameboardDict["s3d0"] = object["s3d0"] as? String ?? ""
        levelModelGameboardDict["s3d1"] = object["s3d1"] as? String ?? ""
        levelModelGameboardDict["s3d2"] = object["s3d2"] as? String ?? ""
        levelModelGameboardDict["s3d3"] = object["s3d3"] as? String ?? ""
        levelModelGameboardDict["s3d4"] = object["s3d4"] as? String ?? ""
        levelModelGameboardDict["s3d5"] = object["s3d5"] as? String ?? ""
        levelModelGameboardDict["s3d6"] = object["s3d6"] as? String ?? ""

        levelModelGameboardDict["s4d0"] = object["s4d0"] as? String ?? ""
        levelModelGameboardDict["s4d1"] = object["s4d1"] as? String ?? ""
        levelModelGameboardDict["s4d2"] = object["s4d2"] as? String ?? ""
        levelModelGameboardDict["s4d3"] = object["s4d3"] as? String ?? ""
        levelModelGameboardDict["s4d4"] = object["s4d4"] as? String ?? ""
        levelModelGameboardDict["s4d5"] = object["s4d5"] as? String ?? ""
        levelModelGameboardDict["s4d6"] = object["s4d6"] as? String ?? ""

        levelModelGameboardDict["s5d0"] = object["s5d0"] as? String ?? ""
        levelModelGameboardDict["s5d1"] = object["s5d1"] as? String ?? ""
        levelModelGameboardDict["s5d2"] = object["s5d2"] as? String ?? ""
        levelModelGameboardDict["s5d3"] = object["s5d3"] as? String ?? ""
        levelModelGameboardDict["s5d4"] = object["s5d4"] as? String ?? ""
        levelModelGameboardDict["s5d5"] = object["s5d5"] as? String ?? ""
        levelModelGameboardDict["s5d6"] = object["s5d6"] as? String ?? ""

        levelModelGameboardDict["s6d0"] = object["s6d0"] as? String ?? ""
        levelModelGameboardDict["s6d1"] = object["s6d1"] as? String ?? ""
        levelModelGameboardDict["s6d2"] = object["s6d2"] as? String ?? ""
        levelModelGameboardDict["s6d3"] = object["s6d3"] as? String ?? ""
        levelModelGameboardDict["s6d4"] = object["s6d4"] as? String ?? ""
        levelModelGameboardDict["s6d5"] = object["s6d5"] as? String ?? ""
        levelModelGameboardDict["s6d6"] = object["s6d6"] as? String ?? ""

        return levelModelGameboardDict
    }
}
