//
//  ResultViewController.swift
//  Quiz App Practice
//
//  Created by Kyle Sherrington on 2021-04-06.
//

import UIKit
protocol ResultViewControllerProtocol {
    
    func dialogDismissed()
    
}


class ResultViewController: UIViewController {

    //MARK: - Variables and Properties
    
    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var dialogView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    var delegate:ResultViewControllerProtocol?
    
    var titleText = ""
    var feedbackText = ""
    var buttonText = ""
    
    // MARK: - Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dialogView.layer.cornerRadius = 10

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // set properties for labels, even though just blank
        titleLabel.text = titleText
        feedbackLabel.text = feedbackText
        dismissButton.setTitle(buttonText, for: .normal)
        
        // hide the UI elements
        dimView.alpha = 0
        titleLabel.alpha = 0
        feedbackLabel.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // fad in the elements
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            
            // fade in the ui elements
            self.dimView.alpha = 1
            self.titleLabel.alpha = 1
            self.feedbackLabel.alpha = 1
            
        }, completion: nil)
        
    }
    
    // MARK: - Methods
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
            
            self.dimView.alpha = 0
            
        } completion: { (completed) in
            
            // dismiss popup
            self.dismiss(animated: true, completion: nil)
            
            // notify delegate popup was dismissed
            self.delegate?.dialogDismissed()
            
        }
        
    }
    
}
