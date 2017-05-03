import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var balanceLabel: UILabel!
    let bankAccount = BankAccount(initialBalance: 80)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didPressWithdraw50(_ sender: Any) {
        DispatchQueue.global().async {
            self.bankAccount.withdraw50Euro() { result in
                self.handle(result: result)
            }
        }
    }
    
    @IBAction func didPressCrazyWithdraws(_ sender: Any) {
        
    }
    
    private func handle(result: Result<Int, BankError>) {
        result.analysis(ifSuccess: { balance in
            DispatchQueue.main.async {
                self.balanceLabel.text = String(balance)
            }
        }, ifFailure: { error in
            showErrorAlert()
        })
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Insufficent founds", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

class BankAccount {
    
    internal private(set) var balance: Int

    init(initialBalance: Int) {
        balance = initialBalance
    }
    
    func withdraw50Euro(completion: @escaping (Result<Int, BankError>) -> Void) {
        if (balance < 50) {
            completion(.failure(.noMoney))
            return
        }
        balance -= 50
        windowsXPLatency()
        completion(.success(balance))
    }
    
    func windowsXPLatency() {
        sleep(arc4random_uniform(UInt32(2)))
    }
}

enum BankError: Error {
    case noMoney
}
