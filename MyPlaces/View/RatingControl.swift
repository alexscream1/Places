//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Alexey Onoprienko on 05.03.2021.
//

import UIKit

class RatingControl: UIStackView {

    
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateSelection()
        }
    }
    
    private var numberOfStars = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        createButtons()
    }
    
    // Rating button pressed
    @objc func buttonPressed(_ button: UIButton) {
        
        guard let index = ratingButtons.firstIndex(of: button) else {return}
        
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    
    private func createButtons() {
        
        // Button images
        
        let empty = #imageLiteral(resourceName: "star")
        let highlighted = #imageLiteral(resourceName: "star2")
        let final = #imageLiteral(resourceName: "star3")
        
        for _ in 0..<numberOfStars {
            
            // Create button
            let button = UIButton()
            button.backgroundColor = .white
            
            // Set button image
            button.setImage(empty, for: .normal)
            button.setImage(highlighted, for: .highlighted)
            button.setImage(highlighted, for: [.highlighted, .selected])
            button.setImage(final, for: .selected)
            
            // Create constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            // Add button target
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            
            // Add button to stack view
            addArrangedSubview(button)
            
            // Add button to rating array
            ratingButtons.append(button)
        }
    }
    
    private func updateSelection() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
        
    }
    
    
}
