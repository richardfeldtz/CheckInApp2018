

import Foundation
import UIKit
import AudioToolbox
import FLAnimatedImage

class GifViewController : UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var gifView: FLAnimatedImageView!
    static var imageName = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        mainView.backgroundColor=UIColor.black
        
        let path1 : String = Bundle.main.path(forResource: GifViewController.imageName, ofType: "gif")!
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
            StudentListViewController.searchController.isActive=false
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}


