# Ashley-Dube-YY-Kude-iOS-Coding-Chalenge

There should be 2 folders; ‘AshDube Chat App’ and ‘Node.js Server’.
Unzip the ‘Node.js Server’ folder.
Open terminal and type: cd “the Node.js Server folder path” then type: node server.js
If there’s a message from the terminal that says: “Server is running on port: 3000”, you can proceed.
Open the ‘AshDube Chat App’ folder and click the ‘AshDube Chat App.xcodeproj’
Once in Xcode, please wait for all the Swift Package Dependencies to download before doing anything.
Wait for the project to finish indexing.
Build the project.
The first view controller to display is the HomeVC and the second is ChatVC.
Run the app on both the iPhone 12 and iPhone 11 Simulators.
*Note: There’s a bug with the ViewDidAppear() function. If you run the app from XCode instead of clicking the icon on the simulator, the App successfully fetches the username from the Realm DB and populates the HomeVC with all online or offline users. However, if you run the app by clicking the icon on the simulator/device, it won’t update the HomeVC with all online or offline users, you have to click the ‘Join’ button and back button then it’ll execute all the code in the ViewDidAppear() function. For best experience, when running the app on the second device, run it from Xcode.
