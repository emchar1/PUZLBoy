//
//  HowToPlayTableView.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/20/23.
//

import UIKit

class HowToPlayTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    private let sectionTerrain = 0
    private let sectionItems = 1
    
    private var terrainItems: [HowToPlayModel] = [
        HowToPlayModel(image: "start", title: "Start", requiredLevel: 0,
                       description: "Your starting point. Tap any available panel adjacent to you to move to it. Diagonal moves are not allowed."),
        HowToPlayModel(image: "endClosed", title: "End", requiredLevel: 0,
                       description: "Collect all the gems to open the gate. Reach the gate in under a certain number of moves to advance."),
        HowToPlayModel(image: "grass", title: "Grass", requiredLevel: 0,
                       description: "Grass is your basic terrain panel - nothing special about it. Stepping on grass will cost you 1 move. 👢"),
        HowToPlayModel(image: "marsh", title: "Poison Marsh", requiredLevel: 19,
                       description: "This crimson colored panel will cost you 2 moves if you're so unlucky to wander into it."),
        HowToPlayModel(image: "ice", title: "Ice", requiredLevel: 76,
                       description: "Walking on this will cause you to slide for only 1 move until you hit an obstacle or other terrain."),
        HowToPlayModel(image: "partytile", title: "Rainbow", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "These colorful panels show up every 50 levels and don't use any moves. Run around to your heart's content!"),
        HowToPlayModel(image: "sand", title: "Sand", requiredLevel: 351,
                       description: "Once you move off of a sand panel, it'll turn into lava, so retracing your steps is a huge no no."),
        HowToPlayModel(image: "lava", title: "Lava", requiredLevel: 351,
                       description: "Just like in real life, lava is SUPER hot. Tread here accidentally and it's instant death."),
    ]
    
    private var overlayItems: [HowToPlayModel] = [
        HowToPlayModel(image: "gem", title: "Gem", requiredLevel: 1,
                       description: "Collect all the purple gems in each level to open the gate and advance to the next level."),
        HowToPlayModel(image: "boulder", title: "Boulder", requiredLevel: 8,
                       description: "Boulders prevent you from passing through. Find a hammer and smash them into a million pieces."),
        HowToPlayModel(image: "hammer", title: "Hammer", requiredLevel: 12,
                       description: "Hammers can break boulders to clear a path. One hammer can break only one boulder, so use them wisely."),
        HowToPlayModel(image: "warp", title: "Yellow Warp", requiredLevel: 34,
                       description: "Stepping on a warp will transport you to the other warp, and vice versa. Don't ask me how it works."),
        HowToPlayModel(image: "enemy", title: "Dragon", requiredLevel: 51,
                       description: "Like boulders, dragons block your path. Unlike boulders, if you touch a dragon, it'll cost you 1 health. 💖"),
        HowToPlayModel(image: "sword", title: "Sword", requiredLevel: 53,
                       description: "A sword can effectively dispatch a dragon to clear a path, so that you can proceed forward."),
        HowToPlayModel(image: "partyGem", title: "Bonus Gem", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "Collect bonus gems to earn special prizes and bonuses, like extra lives. They're sooo shiny!"),
        HowToPlayModel(image: "partyGemTriple", title: "Bonus Gem Multipliers", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "These multipliers add to the bonus gems you've already collected. ...and they're even SHINIER!"),
        HowToPlayModel(image: "partyTime", title: "Time", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "There's never any time! Grab this to add +5 seconds to the clock. Because every second counts!"),
        HowToPlayModel(image: "partyFast", title: "Speed Up", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "These kicks make you go fast! Collect more to go even faster, if that were even possible."),
        HowToPlayModel(image: "partySlow", title: "Speed Down", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "Avoid the blue shoes at all costs... unless you like going really really slow for some reason."),
        HowToPlayModel(image: "partyHint", title: "Magnifying Glass", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "Tapping on the magnifying glass button at the start of a level will point you in the right direction."),
        HowToPlayModel(image: "partyLife", title: "Extra Life", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "If you're able to nab one of these in time, you'll get an extra life at the end of the Bonus Level!"),
        HowToPlayModel(image: "partyBomb", title: "Rainbow Bomb", requiredLevel: Level.partyMinLevelRequired + 1,
                       description: "Don't, I said, DON'T touch these or else your time in the Dark Realm is instantly over. Womp womp."),
        HowToPlayModel(image: "heart", title: "Heart", requiredLevel: 151,
                       description: "Hearts increase your health, protecting against dragon attacks. If your health hits 0 it's game over."),
        HowToPlayModel(image: "warp2", title: "Green Warp", requiredLevel: 251,
                       description: "Just like the Yellow Warp, the Green Warp will teleport you to the next Green Warp. Color coding, yeah!"),
        HowToPlayModel(image: "warp3", title: "Blue Warp", requiredLevel: 401,
                       description: "As if two warps aren't confusing enough, the Blue Warp takes you to, you guessed it... the other Blue Warp.")
    ]
    
    //Must be public
    var currentLevel: Int = 1
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        backgroundColor = .clear
        separatorStyle = .none

        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Table View Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: UIFont.gameFont, size: UIDevice.isiPad ? 36 : 24)
        header.textLabel?.textColor = .cyan
        header.textLabel?.layer.shadowColor = UIColor.black.cgColor
        header.textLabel?.layer.shadowOffset = CGSize(width: -1.5, height: 1.5)
        header.textLabel?.layer.shadowRadius = 0
        header.textLabel?.layer.shadowOpacity = 0.25
        header.sizeToFit()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case sectionTerrain: return "TERRAIN"
        case sectionItems: return "ITEMS/OBSTACLES"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case sectionTerrain: return terrainItems.count
        case sectionItems: return overlayItems.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HowToPlayTVCell.reuseID, for: indexPath) as? HowToPlayTVCell else {
            return UITableViewCell()
        }
        
        var item: HowToPlayModel
        
        switch indexPath.section {
        case sectionTerrain: item = terrainItems[indexPath.row]
        case sectionItems: item = overlayItems[indexPath.row]
        default: item = HowToPlayModel(image: "grass", title: "Error", requiredLevel: 0, description: "Invalid entry.")
        }
        
        cell.setViews(imageName: item.image,
                      title: item.title,
                      requiredLevel: item.requiredLevel,
                      currentLevel: currentLevel,
                      description: item.description)
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UIDevice.isiPad ? 80 : 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HowToPlayTVCell.imageSize + 2 * HowToPlayTVCell.padding
    }
    
    
}
