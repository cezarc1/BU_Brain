 <img src="http://i.imgur.com/XUDBc6t.png" align="middle" height="150">
========

A simple app that interfaces with Binghamton University's BU Brain portal. 

The App is currently in progress and unreleased.

Currently has two features:

1. It gets the users B-Number
2. Gets users schedule for any term

 <img src="http://i.imgur.com/Evb3D8x.png"  height="350">
 <img src="http://i.imgur.com/zdlvWSx.png"  height="350">
 <img src="http://i.imgur.com/v7rK8UG.png"  height="350">

 
## Running

First clone the repo and cd into it

```bash
$ git clone https://github.com/ggamecrazy/BU_Brain.git
$ cd BU_Brain
```
Since this project uses CocoaPods, we will need to build the podfile. 
If you don't have CocoaPods installed run this command:
```bash
$ [sudo] gem install cocoapods
$ pod setup
```
Otherwise:
```bash
$ pod install
```

And Lastly: 
```bash
$ open BU\ Brain.xcworkspace/
```

## Credits

open source projects used:

1. [ObjectiveGumbo](https://github.com/programmingthomas/ObjectiveGumbo) - For parsing HTML

2. [AFNetworking](https://github.com/AFNetworking/AFNetworking) - Network Calls

3. [SSKeychain](https://github.com/soffes/sskeychain) - KeyChain Access wrapper
