//
//  LoginViewController.swift
//  ConnectChats
//
//  Created by Jayden Dagsa on 2/3/21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {

    // Scroll View to auto-layout
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    // Connect Chats logo
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Glyph")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Email field
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemBackground
        return field
    }()
    
    // Password field
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemBackground
        field.isSecureTextEntry = true
        return field
    }()
    
    // Login button
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in!", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    // Facebook Login button
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    private let googleLoginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    // Set UI elements
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        // Adds target to login button
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        // Sets delegate for email and password fields, FB login button
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        // Add sub-views
        view.addSubview(scrollView )
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // Set frames for UI elements
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        loginButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        facebookLoginButton.frame = CGRect(x: 30,
                                  y: loginButton.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        googleLoginButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom+10,
                                         width: scrollView.width-60,
                                         height: 52)
    }
    
    // Function if login button is tapped
    @objc private func loginButtonTapped() {
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // Firebase authentication
        Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Failed to login user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Oops!",
                                      message: "Please enter all information to log in.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // Function if Register button in navbar is tapped
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// Helps conform to delegate rules
extension LoginViewController: UITextFieldDelegate {
    
    // Defines what happens when user taps return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Failed to login user with Facebook.")
            return
        }
        
        let facebookRequest = GraphRequest(graphPath: "me",
                                           parameters: ["fields": "email, name"],
                                           tokenString: token,
                                           version: nil,
                                           httpMethod: .get)
        
        facebookRequest.start(completionHandler: { connection, result, error in
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make FB graph request")
                return
            }
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Failed to get email and name from FB result")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            
            guard nameComponents.count == 2 else {
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName,
                                                                        emailAddress: email))
                }
            })
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard let result = authResult, error == nil else {
                    print("Authentication with FB credentials failed. MFA may be needed. - \(error)")
                    return
                }
                
                print("Successfully logged user in.")
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
            
        })
        
    }
}
