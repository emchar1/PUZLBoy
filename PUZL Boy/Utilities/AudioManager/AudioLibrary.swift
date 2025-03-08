//
//  AudioLibrary.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/8/25.
//

struct AudioLibrary {
    
    ///One static, unmutable property containing all sound effects and music.
    private(set) static var audioItems: [(audioKey: String, category: AudioItem.AudioCategory, maxVolume: Float)] = [
        //Sound FX
        ("arrowblink", .soundFX, 1),
        ("bouldersmash", .soundFX, 1),
        ("boyattack1", .soundFX, 1),
        ("boyattack2", .soundFX, 1),
        ("boyattack3", .soundFX, 1),
        ("boydead", .soundFX, 1),
        ("boygrunt1", .soundFX, 1),
        ("boygrunt2", .soundFX, 1),
        ("boypain1", .soundFX, 1),
        ("boypain2", .soundFX, 1),
        ("boypain3", .soundFX, 1),
        ("boypain4", .soundFX, 1),
        ("boyimpact", .soundFX, 1),
        ("boywin", .soundFX, 1),
        ("buttontap1", .soundFX, 1),
        ("buttontap2", .soundFX, 1),
        ("buttontap3", .soundFX, 1),
        ("buttontap4", .soundFX, 1),
        ("buttontap5", .soundFX, 1), //not purchased $5
        ("buttontap6", .soundFX, 1),
        ("buttontap7", .soundFX, 1),
        ("chatclose", .soundFX, 1),
        ("chatopen", .soundFX, 1),
        ("chatopenelder", .soundFX, 1),
        ("chatopenprincess", .soundFX, 1),
        ("chatopenstatue", .soundFX, 1),
        ("chatopentrainer", .soundFX, 1),
        ("chatopenvillain", .soundFX, 1),
        ("dooropen", .soundFX, 1),
        ("enemydeath", .soundFX, 1),
        ("enemyflame", .soundFX, 1),
        ("enemyice", .soundFX, 1),
        ("enemyroar", .soundFX, 1),
        ("enemyscratch", .soundFX, 1), //not purchased $3
        ("forcefield", .soundFX, 1),
        ("forcefield2", .soundFX, 1),
        ("gemcollect", .soundFX, 1),
        ("gemcollectparty", .soundFX, 1),
        ("gemcollectparty2x", .soundFX, 1),
        ("gemcollectparty3x", .soundFX, 1),
        ("gemcollectpartylife", .soundFX, 1),
        ("hammerswing", .soundFX, 1),
        ("lavaappear1", .soundFX, 1), //not purchased $2
        ("lavaappear2", .soundFX, 1), //not purchased $3
        ("lavaappear3", .soundFX, 1), //not purchased $4
        ("lavasizzle", .soundFX, 1), //not purchased $10
        ("lightsoff", .soundFX, 1),
        ("lightson", .soundFX, 1),
        ("magicblast", .soundFX, 1),
        ("magicdisappear", .soundFX, 1),
        ("magicdisappear2", .soundFX, 1), //NEEDS PURCHASE $2
        ("magicdisappear2b", .soundFX, 1), //NEEDS PURCHASE $1 - either this or the one above!
        ("magicelderbanish", .soundFX, 1),
        ("magicelderexplosion", .soundFX, 1),
        ("magicelderreduce", .soundFX, 1),
        ("magichorrorimpact", .soundFX, 1),
        ("magichorrorimpact2", .soundFX, 1), //NEEDS PURCHASE $2
        ("magicteleport", .soundFX, 1),
        ("magicteleport2", .soundFX, 1),
        ("magicwarp", .soundFX, 1), //not purchased $2
        ("magicwarp2", .soundFX, 1),
        ("marlinblast", .soundFX, 1),
        ("moveglide", .soundFX, 1),
        ("movemarsh1", .soundFX, 1),
        ("movemarsh2", .soundFX, 1),
        ("movemarsh3", .soundFX, 1),
        ("movepoisoned1", .soundFX, 1),
        ("movepoisoned2", .soundFX, 1),
        ("movepoisoned3", .soundFX, 1),
        ("moverun1", .soundFX, 1),
        ("moverun2", .soundFX, 1),
        ("moverun3", .soundFX, 1),
        ("moverun4", .soundFX, 1),
        ("movesand1", .soundFX, 1),
        ("movesand2", .soundFX, 1),
        ("movesand3", .soundFX, 1), //not purchased $5
        ("movesnow1", .soundFX, 1), //not purchased $1
        ("movesnow2", .soundFX, 1),
        ("movesnow3", .soundFX, 1),
        ("movetile1", .soundFX, 1),
        ("movetile2", .soundFX, 1),
        ("movetile3", .soundFX, 1),
        ("movewalk", .soundFX, 1), //not purchased $3
        ("partypill", .soundFX, 1),
        ("partyfast", .soundFX, 1),
        ("partyslow", .soundFX, 1),
        ("pickupheart", .soundFX, 1),
        ("pickupitem", .soundFX, 1),
        ("pickuptime", .soundFX, 1),
        ("punchwhack1", .soundFX, 1),
        ("punchwhack2", .soundFX, 1),
        ("realmtransition", .soundFX, 1),
        ("revive", .soundFX, 1),
        ("sadaccent", .soundFX, 1),
        ("scarylaugh", .soundFX, 1),
        ("shieldcast", .soundFX, 1), //NEEDS PURCHASE $1
        ("shieldcast2", .soundFX, 1), //NEEDS PURCHASE $0
        ("speechbubble", .soundFX, 1), //not purchased $2
        ("swordparry", .soundFX, 1), //NEEDS PURCHASE $1
        ("swordslash", .soundFX, 1),
        ("swordthrow", .soundFX, 1), //NEEDS PURCHASE $1
        ("swordthud", .soundFX, 1), //NEEDS PURCHASE $1
        ("touchstatue", .soundFX, 1),
        ("thunderrumble", .soundFX, 1),
        
        
        //FINAL BATTLE SCENE 2 SFX
        ("villainattack1", .soundFX, 1), //NEEDS PURCHASE $2
        ("villainattack2", .soundFX, 1), //NEEDS PURCHASE $2
        ("villainattack3", .soundFX, 1), //NEEDS PURCHASE $2
        ("villainattackbombtick", .soundFX, 1), //NEEDS PURCHASE $1
        ("villainattackbombticklarge", .soundFX, 1), //NEEDS PURCHASE $1
        ("villainattackspecialbomb", .soundFX, 1), //NEEDS PURCHASE $3
        ("villainattackwand", .soundFX, 1), //NEEDS PURCHASE $1
        ("villaindead", .soundFX, 1), //NEEDS PURCHASE $2
        ("villainpain1", .soundFX, 1), //NEEDS PURCHASE $1
        ("villainpain2", .soundFX, 1), //NEEDS PURCHASE $1
        ("villainpain3", .soundFX, 1), //NEEDS PURCHASE $1
        ("gameendlose", .soundFX, 1),
        ("gameendwin1", .soundFX, 1),
        ("gameendwin2", .soundFXLoop, 1),
        
        
        ("warp", .soundFX, 1),
        ("waterappear1", .soundFX, 1), //not purchased $3
        ("waterappear2", .soundFX, 1),
        ("waterappear3", .soundFX, 1),
        ("waterdrown", .soundFX, 1),
        ("winlevel", .soundFX, 1),
        ("winlevelageofruin", .soundFX, 1),
        ("winlevel3stars", .soundFX, 1),
        ("ydooropen", .soundFX, 1), //NEEDS PURCHASE $1
        ("zdooropen", .soundFX, 1), //TEST FOR FUN ONLY
        
        
        //Looped SFX
        ("clocktick", .soundFXLoop, 1),
        ("littlegirllaugh", .soundFXLoop, 1),
        ("magicdoomloop", .soundFXLoop, 1),
        ("magmoorcreepystrings", .soundFXLoop, 1),
        ("shieldpulse", .soundFXLoop, 1), //NEEDS PURCHASE $1
        
        
        //No Loop music
        ("ageofruin", .musicNoLoop, 1),
        ("ageofruin2", .musicNoLoop, 1),
        ("bossbattle1", .musicNoLoop, 1),
        ("gameover", .musicNoLoop, 1),
        ("gameoverageofruin", .musicNoLoop, 1),
        ("titlechapter", .musicNoLoop, 1),
        ("titletheme", .musicNoLoop, 1),
        ("titlethemeageofruin", .musicNoLoop, 1),
        
        
        //Background music
        ("birdsambience", .music, 0.2),
        ("bossbattle0", .music, 1),
        ("bossbattle2", .music, 1),
        ("bossbattle3", .music, 1),
        ("continueloop", .music, 1),
        ("magicheartbeatloop1", .music, 1),
        ("magicheartbeatloop2", .music, 1),
        ("magmoorcreepypulse", .music, 1),
        ("overworld", .music, 1),
        ("overworldageofruin", .music, 1),
        ("overworldgrassland", .music, 1),
        ("overworldmarimba", .music, 1),
        ("overworldparty", .music, 1),
        ("scarymusicbox", .music, 1)
    ]
    
    
}
