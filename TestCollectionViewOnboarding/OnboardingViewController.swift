
import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    
	var programmedScroll: Bool = false
	
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            currentPage == 0 ? hidePreviousButton() : showPreviousButton()
        }
    }
    private let slides = [
        OnboardingSlide(title: "test 1", subtitle: "some text 1", imageName: "1"),
        OnboardingSlide(title: "test 2", subtitle: "some text 2", imageName: "2"),
        OnboardingSlide(title: "test 3", subtitle: "some text 3", imageName: "3")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInsetAdjustmentBehavior = .never
        pageControl.numberOfPages = slides.count
        currentPage == 0 ? hidePreviousButton() : showPreviousButton()
    }
    
    @IBAction func prevButtonPressed(_ sender: UIButton) {
        if currentPage != 0 {
            currentPage -= 1
            let indexPath = IndexPath(item: currentPage, section: 0)
			// disable scrollViewDidScroll code execution
			self.programmedScroll = true
			collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            //hide onboarding
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
			// disable scrollViewDidScroll code execution
			self.programmedScroll = true
			collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    //MARK: - User Interface Layout Methods
    
    func showPreviousButton() {
        previousButton.setBackgroundImage(UIImage(named: "chevron.backward.circle.fill"), for: .normal)
        previousButton.isUserInteractionEnabled = true
    }
    
    func hidePreviousButton() {
        previousButton.setBackgroundImage(UIImage(named: "chevron.left.circle"), for: .normal)
        previousButton.isUserInteractionEnabled = false
    }
}

//MARK: - CollectionView Delegate Methods

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
            
            cell.imageView.image = UIImage(named: "\(slides[indexPath.row].imageName)")
            cell.mainLabel.text = slides[indexPath.row].title
            cell.subLabel.text = slides[indexPath.row].subtitle
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// don't execute this if WE called scrollToItem
		if !programmedScroll {
			let visibleRectangle = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
			let visiblePoint = CGPoint(x: visibleRectangle.midX, y: visibleRectangle.midY)
			currentPage = collectionView.indexPathForItem(at: visiblePoint)?.row ?? 0
		}
    }
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		// re-enable execution of scrollViewDidScroll code
		programmedScroll = false
	}
	
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()

        let indexPath = IndexPath(item: self.currentPage, section: 0)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

//MARK: - Notes for DonMag
/*
 Hi DonMag, thank you for the help!
 
 1. The best solution I have now is to just delay code running in currentPage like so:
 
 private var currentPage = 0 {
     didSet {
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             self.pageControl.currentPage = self.currentPage
             self.currentPage == 0 ? self.hidePreviousButton() : self.showPreviousButton()
         }
     }
 }
 Then the flickering is invisible for the eye
 
 2. Also I have one one more problem:
 When I change device orientation from landscape to portrait the second slide image being animated and visible within the first slide screen borders.
 
 How to fix the animation so when switching from landscape to portrait I could see only the first item content with a white background on the screen?
 
 This is a separate question on StackOverflow: https://stackoverflow.com/questions/71987822/fix-a-collectionview-animation-while-changing-device-orientation
 */

