# My Food Journal

<kbd><img src="https://static.wixstatic.com/media/be5978_f0629e8f43f64f948c0f48a88cc2c43b~mv2.png/v1/fill/w_488,h_1048,al_c,usm_0.66_1.00_0.01/Overview-NewSize-min.png" title="Overview" width="230" height="500"></kbd>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<kbd><img src="https://static.wixstatic.com/media/be5978_7e47f400d77c45e385edc88696fd3c95~mv2.png/v1/fill/w_488,h_1048,al_c,usm_0.66_1.00_0.01/Nutrition-NewSize-min.png" width="230" height="500"></kbd>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<kbd><img src="https://static.wixstatic.com/media/be5978_b0245d9282a0472b9131b2a47611879e~mv2.png/v1/fill/w_488,h_1048,al_c,usm_0.66_1.00_0.01/Barcode-NewSize-min.png" width="230" height="500"></kbd>

MyFoodJournal is an app that allows you to track everything you eat and log all calorific and nutritional information as well logging and tracking your weight.
User's can add food entries by scanning the barcode of a product, searching the food database or by entering the information manually.
The UI is designed to display all entries and information for each day in an easy-to-read but elegant manner and will also calculate average values for each week and month.
The user can set nutritional and weight goals to stay motivated to be healthy and continue using the application.

This project is built using Xcode 11 and Swift 5.

* In order to download and see project you must have Xcode 9.3 or later installed on your device.
* Use the .xcworkspace file for the frameworks to work.

## Built With

The following third-party frameworks are used in this project:

* [Firebase/Auth](https://firebase.google.com/docs/auth)
* [Firebase/Firestore](https://firebase.google.com/docs/firestore)
* [Charts](https://github.com/danielgindi/Charts)
* [SwiftKeychainWrapper](https://github.com/jrendel/SwiftKeychainWrapper)
* [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD)

## Key Technologies Used

* Networking calls to APIs using URLSession & Codable to retrieve and parse JSON data.
* Integration of Firebase & Firestore with the app to persist and sync data and authenticate users.
* Use of AVFoundation framework to access the camera and scan barcodes.
* Working extensively with dates and PageViewController.
* Delegation and protocols.
* A mixture of Storyboard and Programmatic code to design the UI and set up AutoLayout. 
* Clean, user-friendly UI.

## License

My Food Journal is made available under the GNU General Public License 3.0. Please see LICENSE file for more info.
