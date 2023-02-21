//  EndGameViewController

import UIKit

class EndGameViewController: UIViewController {
    @IBAction func pressNewGame(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBOutlet weak var scoreLabel: UILabel!
    var score: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "\(score)"
    }
}
