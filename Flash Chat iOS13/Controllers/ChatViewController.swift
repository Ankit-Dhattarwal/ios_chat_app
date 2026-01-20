

import UIKit
import FirebaseAuth

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "⚡️FlashChat"
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth();
        navigationController?.popViewController(animated: true)
        do{
            try firebaseAuth.signOut()
        }catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
