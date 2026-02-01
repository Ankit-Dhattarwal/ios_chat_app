import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*
         Type Checking::
         ---------------
         is :- This keyword use for the type checking
         Example:
         let cell = UITableViewCell()
         if cell is UITableVIewCell {
         print("Cell type are UITableViewCell")
         }
         
         Forced Downcast::
         -----------------
         
         as! & as?  :- This keyword use for the convert sub- class if sub class have some functionality or we need to use. Note { If we now the sub- item is type of B class then we use as with ! [ as! ]
              because we know this is type of that and we use this as!. if we are not sure then use as?
         Example:
         let cell = UITableViewCell()
         
         let messageCell = cell as! MessageCell
         
         */
//        tableView.delegate = self
        tableView.dataSource = self
        title = Constants.appName
        navigationItem.hidesBackButton = true
        
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
    }
    
    func loadMessages(){
        messages = []
        
        db.collection(Constants.FStore.collectionName).order(by: Constants.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("There is an issue retrieving data from Firestore: \(e)")
            } else if let snapshotDocuments = querySnapshot?.documents {
                var loadedMessages: [Message] = []
                for doc in snapshotDocuments {
                    let data = doc.data()
                    if let sender = data[Constants.FStore.senderField] as? String,
                       let body = data[Constants.FStore.bodyField] as? String {
                        loadedMessages.append(Message(sender: sender, body: body))
                    }
                }
                self.messages = loadedMessages
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text , let sender = Auth.auth().currentUser?.email {
            db.collection(Constants.FStore.collectionName).addDocument(data: [
                Constants.FStore.senderField: sender,
                Constants.FStore.bodyField: messageBody,
                Constants.FStore.dateField: Date().timeIntervalSince1970
            ]){
                (error) in
                if let e = error{
                    print("There an issue saving data to Firestore \(e)")
                }else{
                    print("Successfully data saved.")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                
                }
            }
        }
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


extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messages =  messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label?.text = messages.body
        
        //This message from the current user
        if messages.sender == Auth.auth().currentUser?.email {
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden  = false
            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.purple)
        }else{
            cell.rightImageView.isHidden = false
            cell.leftImageView.isHidden  = true
            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.purple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.lightPurple)
        }
        
        return cell;
        
    }
    
    
}

//extension ChatViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//    }
//}

