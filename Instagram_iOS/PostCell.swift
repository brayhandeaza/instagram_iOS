//
//  PostCell.swift
//  Instagram_iOS
//
//  Created by Brayhan De Aza on 10/23/20.
//

import UIKit

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var caption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}