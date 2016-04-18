# pong

This is my implementation of the classic video game Pong in Swift using the SpriteKit graphics library. The source code in its entirety can be found in the `Pong` subfolder (this is the default Xcode project structure). It has not been modified recently, however, the commit history is publicly reviewable.
The nature of this project is a simple Pong game that showcases different AIs and how they work. There are two AI categories: `PongBasicPlayer` and `PongTrigPlayer`.

## Build instructions

Due to Swift's transient state and the application's dependency upon target-specific bindings like `NSWindow`, as well as closed libraries like `SpriteKit`, this program has strict build requirements.

This is a **Swift 2.2** application targeting the latest public version of **OS X El Capitan**.

To build and run, open the Xcode project file (included) in Xcode and build it through there. You can even run it directly after building by pressing the ▶️ button. Because it is Swift 2.2, I advise using the latest App Store version of Xcode.

Once built, the program will either run immediately, or, if you specificied **Build Only**, the application binary will appear in the **Products** folder in the Xcode left side tree, allowing you to access the binary directly.
