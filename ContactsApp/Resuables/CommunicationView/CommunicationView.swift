//
//  CommunicationButton.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 12/16/20.
//

import UIKit

protocol CommunicationViewDelegate: AnyObject {
    func communicationViewDidTap(_ view: CommunicationView)
}

class CommunicationView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    weak var delegate: CommunicationViewDelegate?
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        return tapGesture
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView.layer.cornerRadius = 8
        contentView.addGestureRecognizer(tapGesture)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CommunicationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configure(_ image: UIImage?, title: String) {
        imageView.image = image
        titleLabel.text = title
    }
    
    func setEnabled(_ enabled: Bool) {
        if enabled {
            alpha = 1
        } else {
            alpha = 0.5
        }
        
    }
    
    @objc func didTap() {
        delegate?.communicationViewDidTap(self)
    }
}
