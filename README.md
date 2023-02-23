# HotProspects
Hacking with swift project 16. App to add people by scanning a qrCode automatically generated when entering their data. Distinction between contacted and non-contacted users. Possibility of sorting users by name or registration date

<h1>What to do?</h1>
To make the app work you need to add the CodeScanner package and its available on GitHub under the MIT license at https://github.com/twostraws/CodeScanner. Here, though, we’re just going to add it to Xcode by following these steps:
<ul>
<li>
Go to File > Swift Packages > Add Package Dependency.
</li>
<li>
Enter https://github.com/twostraws/CodeScanner as the package repository URL.
</li>
<li>
For the version rules, leave “Up to Next Major” selected, which means you’ll get any bug fixes and additional features but not any breaking changes.
</li>
<li>
Press Finish to import the finished package into your project.
</li>
<br>
That's it!
