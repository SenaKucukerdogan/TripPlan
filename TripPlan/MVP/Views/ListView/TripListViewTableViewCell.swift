//
//  ListViewTableViewCell.swift
//  TripPlan
//
//  Created by Sena Küçükerdoğan on 14.06.2023.
//

import UIKit

protocol TripListViewCellDelegate: AnyObject {
    func bookButtonTapped(for cell: TripListViewTableViewCell)
}

class TripListViewTableViewCell: UITableViewCell {

    @IBOutlet weak var busNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    weak var delegate: TripListViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func bookButton(_ sender: Any) {
        delegate?.bookButtonTapped(for: self)
    }
    

}
