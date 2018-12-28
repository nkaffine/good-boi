# Good Boi?
Good Boi is an app I created to test out CreateML, CoreML, and the Vision framework in a pretty simple way. The app was trained on a dataset of 2,000 images. I grabbed all of the pictures of dogs from r/DOG on reddit. All of the pictures of not dogs came from various other subreddits and some google searches (for things that I couldn't find any subreddits for).

# AVHandler
In the original design of the app I had all of the image capture logic in the main view controller to get started. After I got everything working I decided to move that logic to it's own class. The two ways I thought about moving this logic was to subclass UIViewController and to create a separate class. 

I decided to go with a seperate class to handle all of the image capture logic because I believe that this makes it slighlty more flexible than subclassing a UIViewController.The AVHandler has a function setupPreviewLayer(on view: UIView) which gives the option to have the capture preview be placed on any view allowing flexibility in size of the preview. 

# DogClassifierModel
I decided to wrap the interaction with the Vision framework to make it easier to work with and because I plan on eventually abstracting away the specifics of this model so that this wrapper can be applied to other classification models easier. I will probably have the generic wrapper be passed a CoreMLModel to use and have the generic type be an enum that will convert the identifier returned by the classifier model to the enum and return that. That should give it the flexibility to work with any type of classification model.
