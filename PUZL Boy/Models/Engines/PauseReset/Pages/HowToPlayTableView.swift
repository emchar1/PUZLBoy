//
//  HowToPlayTableView.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/20/23.
//

import UIKit

class HowToPlayTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var terrainItems: [HowToPlayModel] = [
        HowToPlayModel(image: "start", title: "Start", requiredLevel: 0,
                       description: "Your starting point. PUZL Boy begins each level on this panel."),
        HowToPlayModel(image: "endClosed", title: "End", requiredLevel: 0,
                       description: "Your ending point. You'll need to collect all the gems to open the gate and move on to the next level."),
        HowToPlayModel(image: "grass", title: "Grass", requiredLevel: 0,
                       description: "Your typical terrain. Stepping on grass will cost you 1 move. Diagonal moves are not allowed."),
        HowToPlayModel(image: "marsh", title: "Poison Marsh", requiredLevel: 19,
                       description: "This crimson colored panel will cost you 2 moves if you're so unlucky to wander into it."),
        HowToPlayModel(image: "ice", title: "Ice", requiredLevel: 76,
                       description: "Walking on this will cause you to slide for only 1 move until you hit an obstacle or other terrain."),
        HowToPlayModel(image: "partytile", title: "Rainbow", requiredLevel: 100,
                       description: "These tiles don't take up any moves and are here for your enjoyment. Run around to your heart's content!"),
        HowToPlayModel(image: "sand", title: "Sand", requiredLevel: 351,
                       description: "Once you move off of a sand panel, it'll turn into lava, so retracing your steps is a huge no no."),
        HowToPlayModel(image: "lava", title: "Lava", requiredLevel: 351,
                       description: "Just like in real life, lava is SUPER hot. Tread here accidentally and it's instant death."),
    ]
    
    var overlayItems: [HowToPlayModel] = [
        HowToPlayModel(image: "gem", title: "Gem", requiredLevel: 1,
                       description: "Collect all the gems in each level to open the gate and advance to the next level."),
        HowToPlayModel(image: "boulder", title: "Boulder", requiredLevel: 8,
                       description: "Boulders block you from passing through. Find a hammer and smash them to bits."),
        HowToPlayModel(image: "hammer", title: "Hammer", requiredLevel: 12,
                       description: "Hammers can break boulders to clear a path. One hammer can break only one boulder."),
        HowToPlayModel(image: "warp", title: "Yellow Warp", requiredLevel: 34,
                       description: "Stepping on a warp will transport you to the other warp, and vice versa. Don't ask me how it works."),
        HowToPlayModel(image: "enemy", title: "Enemy", requiredLevel: 51,
                       description: "Like boulders, dragons block your path. Unlike boulders, if you touch a dragon, it'll cost you 1 health."),
        HowToPlayModel(image: "sword", title: "Sword", requiredLevel: 53,
                       description: "A sword can dispatch a dragon effectively to clear a path so you can proceed."),
        HowToPlayModel(image: "gemparty", title: "Party Gem", requiredLevel: 100,
                       description: "Collect party gems to earn extra lives. Sooo shiny!"),
        HowToPlayModel(image: "heart", title: "Heart", requiredLevel: 151,
                       description: "Hearts increase your health, protecting against dragon attacks. If your health hits 0 it's game over."),
        HowToPlayModel(image: "warp2", title: "Green Warp", requiredLevel: 251,
                       description: "Just like the Yellow Warp, the Green Warp will teleport you to the next Green Warp. Color coding yeah!"),
        HowToPlayModel(image: "warp3", title: "Blue Warp", requiredLevel: 401,
                       description: "As if two warps aren't enough, the Blue Warp takes you to, you guessed it, the other Blue Warp.")
    ]
    
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
        header.textLabel?.font = UIFont(name: UIFont.gameFont, size: UIDevice.isiPad ? 32 : 20)
        header.textLabel?.textColor = UIFont.gameFontColor
        header.textLabel?.layer.shadowOffset = CGSize(width: -2, height: 2)
        header.textLabel?.layer.shadowColor = UIColor.gray.cgColor
        header.textLabel?.layer.shadowOpacity = 0.75
        header.sizeToFit()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "TERRAIN"
        case 1: return "ITEMS/OBSTACLES"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return terrainItems.count
        case 1: return overlayItems.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HowToPlayTVCell.reuseID, for: indexPath) as? HowToPlayTVCell else {
            return UITableViewCell()
        }
        
        var item: HowToPlayModel
        
        switch indexPath.section {
        case 0: item = terrainItems[indexPath.row]
        case 1: item = overlayItems[indexPath.row]
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
