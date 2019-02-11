

import Foundation
import UIKit
import AudioToolbox
import 

class GifViewController : UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var gifView: FLAnimatedImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        mainView.backgroundColor=UIColor.black
        
        let path1 : String = Bundle.main.path(forResource: "lj", ofType: "gif")!
        let url = URL(fileURLWithPath: path1)
        do{
            let gifData = try Data(contentsOf: url)
            let imageData = FLAnimatedImage(animatedGIFData: gifData)
            gifView.animatedImage = imageData
        }
        catch _ as NSError{
            print("Error setting gif image")
        }
        StudentListViewController.searchController.searchBar.text=nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}


