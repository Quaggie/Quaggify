//
//  LoginViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class LoginViewController: ViewController {
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Quaggify"
    label.textColor = ColorPalette.white
    label.font = Font.montSerratRegular(size: 36)
    label.textAlignment = .center
    return label
  }()
  
  lazy var loginButton: UIButton = {
    let button = UIButton(type: .system)
    button.tintColor = .white
    button.setTitle("Login with Spotify", for: .normal)
    button.titleLabel?.font = Font.montSerratBold(size: 16)
    button.addTarget(self, action: #selector(login), for: .touchUpInside)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  @objc func login () {
    SpotifyService.shared.login()
  }
  
  override func setupViews() {
    super.setupViews()
    view.backgroundColor = ColorPalette.black
    
    view.addSubview(titleLabel)
    view.addSubview(loginButton)
    
    titleLabel.anchorCenterYToSuperview()
    titleLabel.anchor(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 40)
    
    loginButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 32)
  }

}
