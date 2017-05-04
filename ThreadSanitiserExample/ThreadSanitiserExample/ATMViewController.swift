import UIKit

class ATMViewController: UIViewController {

    @IBOutlet weak var balanceLabel: UILabel!
    let bankAccount = BankAccount()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didPressWithdraw50(_ sender: Any) {
        self.bankAccount.withdraw50Euro() { result in
            self.handle(result: result)
        }
    }
    
    @IBAction func didPressWithdraw50OnBackground(_ sender: Any) {

        DispatchQueue.global(qos: .background).async {

            self.bankAccount.withdraw50Euro() { result in
                self.handle(result: result)
                DispatchQueue.main.async {
                    self.showBalance()
                }
            }
        }
    }
    
    @IBAction func didPressResetBalance(_ sender: Any) {
        bankAccount.resetBalance(to: 80)
        showBalance()
    }
    
    private func handle(result: Result<Int, BankError>) {
        result.analysis(ifSuccess: { balance in
            DispatchQueue.main.async {
                self.showBalance()
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
    
    private func showBalance() {
        balanceLabel.text = String(bankAccount.balance)
    }
}

class BankAccount {
    
    internal private(set) var balance: Int //sharedResource that should be thread-safe

    init() {
        balance = 80
    }
    
    func resetBalance(to balance: Int){
        self.balance = balance
    }
    
    func withdraw50Euro(completion: @escaping (Result<Int, BankError>) -> Void) {
        //Critical section
        if (balance < 50) {
            printWithThread("Balance is lower than 50, you can't withdraw")
            completion(.failure(.noMoney))
            return
        }
        printWithThread("Balance is higher than 50, let's take the money!")
        windowsXPLatency()
        balance -= 50
        printWithThread("Balance updated to \(balance)")
        completion(.success(balance))
    }
    
    func windowsXPLatency() {
        sleep(3)
    }
}

func printWithThread(_ text: String){
    print("\(text) - on thread \(Thread.current.description)")
}

enum BankError: Error {
    case noMoney
}
