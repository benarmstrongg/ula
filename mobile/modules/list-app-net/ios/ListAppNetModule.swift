import ExpoModulesCore

protocol Listener {
    func listen(log: @escaping (_: String) -> Void) -> Self
}

protocol Browser {
    var queue: DispatchQueue { get }
    var protocolName: String { get }
    var discoverDeviceHandler: (_ result: NWBrowser.Result) -> Void { get }

    func onDiscoverDevice(_ handler: @escaping (_ result: NWBrowser.Result) -> Void) -> Self
    func browse() -> Self
}

class HttpListener: Listener {
    private var listener: NWListener?
    let queue: DispatchQueue = .init(label: "http.bg.queue3", attributes: [])
    var errDelete: String?

    init() {
        do {
            // listener = try NWListener(
            //     service: .init(type: "_http._tcp"),
            //     using: .init(tls: nil, tcp: NWProtocolTCP.Options())
            // )
            listener = try NWListener(using: NWParameters(tls: nil, tcp: NWProtocolTCP.Options()), on: 8888)
            listener?.service = NWListener.Service(name: "OK", type: "_listapp._tcp")
        } catch {
            errDelete = "error"
        }
    }

    func listen(log: @escaping (_: String) -> Void) -> Self {
        listener?.newConnectionHandler = { conn in
            log("\(conn)")
        }
        listener?.stateUpdateHandler = { state in
            switch state {
            case let .failed(NWError.posix(err)):
                log("\(err)")
            case .ready:
                log("listening on \(self.listener?.port)")
            default:
                log("uhh")
            }
        }
        listener?.start(queue: queue)
        return self
    }
}

class HttpBrowser: Browser {
    private let browser: NWBrowser
    let protocolName: String = "http"
    let queue: DispatchQueue = .init(label: "http.bg.queue", attributes: [])
    let queue2: DispatchQueue = .init(label: "http.bg.queue2", attributes: [])
    var discoverDeviceHandler: (_ result: NWBrowser.Result) -> Void

    init() {
        browser = NWBrowser(
            for: .bonjour(type: "_listapp._tcp", domain: nil),
            using: NWParameters(tls: nil, tcp: NWProtocolTCP.Options())
        )
        discoverDeviceHandler = { _ in }
    }

    func onDiscoverDevice(_ handler: @escaping (_ result: NWBrowser.Result) -> Void) -> Self {
        discoverDeviceHandler = handler
        return self
    }

    func connect(
        _ endpoint: NWEndpoint,
        onData: @escaping (_: String) -> Void,
        onStateChange: @escaping (_: NWConnection.State?) -> Void,
        onError _: @escaping (NWError?) -> Void
    ) {
        let tcpOptions = NWProtocolTCP.Options()
        // tcpOptions.connectionTimeout = 5
        // tcpOptions.enableKeepalive = true
        let connection = NWConnection(
            to: endpoint,
            using: NWParameters(tls: nil, tcp: tcpOptions)
        )
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                onStateChange(state)
                // connection.send(
                //     content: "test123".data(using: .utf8),
                //     completion: .contentProcessed { (err: NWError?) in
                //         if err != nil {
                //             return onError(err)
                //         }
                //     }
                // )
                onData("sent write")
                connection.receiveMessage(
                    completion: { (data: Data?, _: NWConnection.ContentContext?, isComplete: Bool, _: NWError?) in
                        if let data = data, !data.isEmpty {
                            if let string = String(data: data, encoding: .utf8) {
                                onData("\(string)")
                            }
                        } else {
                            onData("no data")
                        }
                        onData("isComplete = \(isComplete)")
                    }
                )
            default:
                onStateChange(state)
            }
        }
        connection.start(queue: queue2)
    }

    func browse() -> Self {
        browser.start(queue: queue)

        log("started mdns browser looking for \(protocolName)")

        browser.browseResultsChangedHandler =
            { (results: Set<NWBrowser.Result>, _: Set<NWBrowser.Result.Change>) in
                for result in results {
                    self.discoverDeviceHandler(result)
                }
            }

        return self
    }
}

public class ListAppNetModule: Module {
    // var udpListener: NWListener?
    // var backgroundQueueUdpListener = DispatchQueue(label: "udp-lis.bg.queue", attributes: [])
    // var backgroundQueueUdpConnection = DispatchQueue(label: "udp-con.bg.queue", attributes: [])

    // var nwBrowser: NWBrowser?
    // var backgroundQueueNwBrowser = DispatchQueue(label: "browser.bg.queue", attributes: [])

    // var connections = [NWConnection]()

    let httpBrowser: HttpBrowser = .init()
    let httpListener: HttpListener = .init()

    public func definition() -> ModuleDefinition {
        Name("ListAppNet")
        Events("log")

        Function("startDiscovery") { () in
        }

        // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
        Function("hello") { () -> String in
            // Create the listener object.
            // let listener = try NWListener(using: NWParameters())
            // // Set the service to advertise.
            // listener.service = NWListener.Service(name: "Test123", type: "_tictactoe._tcp")

            // func listenerStateChanged(newState: NWListener.State) {
            //     switch newState {
            //     case .ready:
            //         log("Listener ready on \(String(describing: listener.port))")
            //     case let .failed(error):
            //         if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_DefunctConnection)) {
            //             log("Listener failed with \(error), restarting")
            //             listener.cancel()
            //             // setupBonjourListener()
            //         } else {
            //             log("Listener failed with \(error), stopping")
            //             self.displayAdvertiseError(error)
            //             listener.cancel()
            //         }
            //     case .cancelled:
            //         bonjourListener = nil
            //     default:
            //         break
            //     }

            // guard self.udpListener == nil else {
            //     log("Already listening. Not starting again")
            //     return "already listening"
            // }

            // do {
            //     let tcpOptions = NWProtocolTCP.Options()
            //     tcpOptions.enableKeepalive = true
            //     tcpOptions.keepaliveIdle = 2
            //     let parameters = NWParameters(tls: nil, tcp: tcpOptions)
            //     parameters.includePeerToPeer = true
            //     self.udpListener = try NWListener(using: parameters, on: 42069)
            //     self.udpListener?.stateUpdateHandler = { listenerState in
            //         self.log("👂🏼👂🏼👂🏼 NWListener Handler called")
            //         switch listenerState {
            //         case .setup:
            //             self.log("Listener: Setup")
            //         case let .waiting(error):
            //             self.log("Listener: Waiting \(error)")
            //         case .ready:
            //             self.log(
            //         "Listener: ✅ Ready and listens on port: \(self.udpListener?.port?.debugDescription ?? "-")"
            //             )
            //         case let .failed(error):
            //             self.log("Listener: Failed \(error)")
            //             self.udpListener = nil
            //         case .cancelled:
            //             self.log("Listener: 🛑 Cancelled by myOffButton")
            //             for connection in self.connections {
            //                 connection.cancel()
            //             }
            //             self.udpListener = nil
            //         default:
            //             break
            //         }
            //     }

            //     // self.udpListener?.service = NWListener.Service(applicationService: "test123")
            //     // self.udpListener?.service =
            //     NWListener.Service(name: "http", type: "_listapp._tcp")
            //     // self.udpListener?.service = NWListener.Service(applicationService: "http")
            //     self.udpListener?.start(queue: backgroundQueueUdpListener)
            //     self.udpListener?.newConnectionHandler = { incomingUdpConnection in
            //         self.log("📞📞📞 NWConnection Handler called ")
            //         incomingUdpConnection.stateUpdateHandler = { udpConnectionState in

            //             switch udpConnectionState {
            //             case .setup:
            //                 self.log("Connection: 👨🏼‍💻 setup")
            //             case let .waiting(error):
            //                 self.log("Connection: ⏰ waiting: \(error)")
            //             case .ready:
            //                 self.log("Connection: ✅ ready")
            //                 self.connections.append(incomingUdpConnection)
            //                 self.processData(incomingUdpConnection)
            //             case let .failed(error):
            //                 self.log("Connection: 🔥 failed: \(error)")
            //                 self.connections.removeAll(where: { incomingUdpConnection === $0 })
            //             case .cancelled:
            //                 self.log("Connection: 🛑 cancelled")
            //                 self.connections.removeAll(where: { incomingUdpConnection === $0 })
            //             default:
            //                 break
            //             }
            //         }

            //         incomingUdpConnection.start(queue: self.backgroundQueueUdpConnection)
            //     }

            // } catch {
            //     log("🧨🧨🧨 CATCH")
            // }

            self.httpListener.listen(log: { msg in self.log("\(msg)") })

            // self.httpBrowser.onDiscoverDevice { (result: NWBrowser.Result) in
            //     self.log(result.endpoint.debugDescription)
            //     if result.endpoint.debugDescription.contains("test") {
            //         self.log("test found")
            //         self.httpBrowser.connect(
            //             result.endpoint,
            //             onData: { state in self.log("data, \(state)") },
            //             onStateChange: { state in self.log("state_change, \(state)") },
            //             onError: { error in self.log("\(error)") }
            //         )
            //     }
            //     self.log("hello \(result)")
            // }.browse()

            // listener.stateUpdateHandler = listenerStateChanged

            // // The system calls this when a new connection arrives at the listener.
            // // Start the connection to accept it, cancel to reject it.
            // listener.newConnectionHandler = { (newConnection: NWConnection) in
            //     self.log(newConnection.debugDescription)
            //     if sharedConnection == nil {
            //         // Accept a new connection.
            //         sharedConnection = PeerConnection(connection: newConnection, delegate: self)
            //     } else {
            //         // If a game is already in progress, reject it.
            //         newConnection.cancel()
            //     }
            // }

            // // Start listening, and request updates on the main queue.
            // listener.start(queue: .main)

            return "hello"
        }
    }

    func processData(_ incomingUdpConnection: NWConnection) {
        incomingUdpConnection.receiveMessage(completion: { data, _, isComplete, error in

            if let data = data, !data.isEmpty {
                if let string = String(data: data, encoding: .ascii) {
                    self.log("DATA       = \(string)")
                }
            }
            // print ("context    = \(context)")
            self.log("isComplete = \(isComplete)")
            if error == nil {
                self.processData(incomingUdpConnection)
            }
        })
    }

    private func log(_ msg: String) {
        print(msg)
        sendEvent("log", [
            "msg": msg,
        ])
    }
}

/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 Implement a custom framer protocol to encode game-specific messages over a stream.
 */

import Foundation
import Network

// Define the types of commands for your game to use.
enum GameMessageType: UInt32 {
    case invalid = 0
    case selectedCharacter = 1
    case move = 2
}

// Create a class that implements a framing protocol.
class GameProtocol: NWProtocolFramerImplementation {
    // Create a global definition of your game protocol to add to connections.
    static let definition = NWProtocolFramer.Definition(implementation: GameProtocol.self)

    // Set a name for your protocol for use in debugging.
    static var label: String { return "TicTacToe" }

    // Set the default behavior for most framing protocol functions.
    required init(framer _: NWProtocolFramer.Instance) {}
    func start(framer _: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult { return .ready }
    func wakeup(framer _: NWProtocolFramer.Instance) {}
    func stop(framer _: NWProtocolFramer.Instance) -> Bool { return true }
    func cleanup(framer _: NWProtocolFramer.Instance) {}

    // Whenever the application sends a message, add your protocol header and forward the bytes.
    func handleOutput(
        framer: NWProtocolFramer.Instance,
        message: NWProtocolFramer.Message,
        messageLength: Int,
        isComplete _: Bool
    ) {
        // Extract the type of message.
        let type = message.gameMessageType

        // Create a header using the type and length.
        let header = GameProtocolHeader(type: type.rawValue, length: UInt32(messageLength))

        // Write the header.
        framer.writeOutput(data: header.encodedData)

        // Ask the connection to insert the content of the app message after your header.
        do {
            try framer.writeOutputNoCopy(length: messageLength)
        } catch {
            print("Hit error writing \(error)")
        }
    }

    // Whenever new bytes are available to read, try to parse out your message format.
    func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        while true {
            // Try to read out a single header.
            var tempHeader: GameProtocolHeader?
            let headerSize = GameProtocolHeader.encodedSize
            let parsed = framer.parseInput(
                minimumIncompleteLength: headerSize,
                maximumLength: headerSize,
                parse: { buffer, _ -> Int in
                    guard let buffer = buffer
                    else {
                        return 0
                    }
                    if buffer.count < headerSize {
                        return 0
                    }
                    tempHeader = GameProtocolHeader(buffer)
                    return headerSize
                }
            )

            // If you can't parse out a complete header, stop parsing and return headerSize,
            // which asks for that many more bytes.
            guard parsed, let header = tempHeader
            else {
                return headerSize
            }

            // Create an object to deliver the message.
            var messageType = GameMessageType.invalid
            if let parsedMessageType = GameMessageType(rawValue: header.type) {
                messageType = parsedMessageType
            }
            let message = NWProtocolFramer.Message(gameMessageType: messageType)

            // Deliver the body of the message, along with the message object.
            if !framer.deliverInputNoCopy(
                length: Int(header.length),
                message: message,
                isComplete: true
            ) {
                return 0
            }
        }
    }
}

// Extend framer messages to handle storing your command types in the message metadata.
extension NWProtocolFramer.Message {
    convenience init(gameMessageType: GameMessageType) {
        self.init(definition: GameProtocol.definition)
        self["GameMessageType"] = gameMessageType
    }

    var gameMessageType: GameMessageType {
        if let type = self["GameMessageType"] as? GameMessageType {
            return type
        } else {
            return .invalid
        }
    }
}

// Define a protocol header structure to help encode and decode bytes.
struct GameProtocolHeader: Codable {
    let type: UInt32
    let length: UInt32

    init(type: UInt32, length: UInt32) {
        self.type = type
        self.length = length
    }

    init(_ buffer: UnsafeMutableRawBufferPointer) {
        var tempType: UInt32 = 0
        var tempLength: UInt32 = 0
        withUnsafeMutableBytes(of: &tempType) { typePtr in
            typePtr.copyMemory(from: UnsafeRawBufferPointer(start: buffer.baseAddress!.advanced(by: 0),
                                                            count: MemoryLayout<UInt32>.size))
        }
        withUnsafeMutableBytes(of: &tempLength) { lengthPtr in
            lengthPtr.copyMemory(from: UnsafeRawBufferPointer(
                start: buffer.baseAddress!.advanced(by: MemoryLayout<UInt32>.size),
                count: MemoryLayout<UInt32>.size
            ))
        }
        type = tempType
        length = tempLength
    }

    var encodedData: Data {
        var tempType = type
        var tempLength = length
        var data = Data(bytes: &tempType, count: MemoryLayout<UInt32>.size)
        data.append(Data(bytes: &tempLength, count: MemoryLayout<UInt32>.size))
        return data
    }

    static var encodedSize: Int {
        return MemoryLayout<UInt32>.size * 2
    }
}

var bonjourListener: PeerListener?
var applicationServiceListener: PeerListener?

class PeerListener {
    enum ServiceType {
        case bonjour
        case applicationService
    }

    weak var delegate: PeerConnectionDelegate?
    var listener: NWListener?
    var name: String?
    let passcode: String?
    let type: ServiceType

    // Create a listener with a name to advertise, a passcode for authentication,
    // and a delegate to handle inbound connections.
    init(name: String, passcode: String, delegate: PeerConnectionDelegate) {
        type = .bonjour
        self.delegate = delegate
        self.name = name
        self.passcode = passcode
        setupBonjourListener()
    }

    // Create a listener that advertises the game's app service
    // and has a delegate to handle inbound connections.
    init(delegate: PeerConnectionDelegate) {
        type = .applicationService
        self.delegate = delegate
        name = nil
        passcode = nil
        setupApplicationServiceListener()
    }

    func setupApplicationServiceListener() {
        do {
            // Create the listener object.
            let listener = try NWListener(using: applicationServiceParameters())
            self.listener = listener

            // Set the service to advertise.
            listener.service = NWListener.Service(applicationService: "TicTacToe")

            startListening()
        } catch {
            print("Failed to create application service listener")
            abort()
        }
    }

    // Start listening and advertising.
    func setupBonjourListener() {
        do {
            // When hosting a game via Bonjour, use the passcode and advertise the _tictactoe._tcp service.
            guard let name = name, let passcode = passcode
            else {
                print("Cannot create Bonjour listener without name and passcode")
                return
            }

            // Create the listener object.
            let listener = try NWListener(using: NWParameters())
            self.listener = listener

            // Set the service to advertise.
            listener.service = NWListener.Service(name: name, type: "_tictactoe._tcp")

            startListening()
        } catch {
            print("Failed to create bonjour listener")
            abort()
        }
    }

    func bonjourListenerStateChanged(newState: NWListener.State) {
        switch newState {
        case .ready:
            print("Listener ready on \(String(describing: listener?.port))")
        case let .failed(error):
            if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_DefunctConnection)) {
                print("Listener failed with \(error), restarting")
                listener?.cancel()
                setupBonjourListener()
            } else {
                print("Listener failed with \(error), stopping")
                delegate?.displayAdvertiseError(error)
                listener?.cancel()
            }
        case .cancelled:
            bonjourListener = nil
        default:
            break
        }
    }

    func applicationServiceListenerStateChanged(newState: NWListener.State) {
        switch newState {
        case .ready:
            print("Listener ready for nearby devices")
        case let .failed(error):
            print("Listener failed with \(error), stopping")
            delegate?.displayAdvertiseError(error)
            listener?.cancel()
        case .cancelled:
            applicationServiceListener = nil
        default:
            break
        }
    }

    func listenerStateChanged(newState: NWListener.State) {
        switch type {
        case .bonjour:
            bonjourListenerStateChanged(newState: newState)
        case .applicationService:
            applicationServiceListenerStateChanged(newState: newState)
        }
    }

    func startListening() {
        listener?.stateUpdateHandler = listenerStateChanged

        // The system calls this when a new connection arrives at the listener.
        // Start the connection to accept it, cancel to reject it.
        listener?.newConnectionHandler = { newConnection in
            if let delegate = self.delegate {
                if sharedConnection == nil {
                    // Accept a new connection.
                    sharedConnection = PeerConnection(connection: newConnection, delegate: delegate)
                } else {
                    // If a game is already in progress, reject it.
                    newConnection.cancel()
                }
            }
        }

        // Start listening, and request updates on the main queue.
        listener?.start(queue: .main)
    }

    // Stop listening.
    func stopListening() {
        if let listener = listener {
            listener.cancel()
            switch type {
            case .bonjour:
                bonjourListener = nil
            case .applicationService:
                applicationServiceListener = nil
            }
        }
    }

    // If the user changes their name, update the advertised name.
    func resetName(_ name: String) {
        guard type == .bonjour
        else {
            return
        }

        self.name = name
        if let listener = listener {
            // Reset the service to advertise.
            listener.service = NWListener.Service(name: self.name, type: "_tictactoe._tcp")
        }
    }
}

// Create parameters for use in PeerConnection and PeerListener with app services.
func applicationServiceParameters() -> NWParameters {
    let parameters = NWParameters.applicationService

    // Add your custom game protocol to support game messages.
    let gameOptions = NWProtocolFramer.Options(definition: GameProtocol.definition)
    parameters.defaultProtocolStack.applicationProtocols.insert(gameOptions, at: 0)

    return parameters
}

var sharedConnection: PeerConnection?

protocol PeerConnectionDelegate: AnyObject {
    func connectionReady()
    func connectionFailed()
    func receivedMessage(content: Data?, message: NWProtocolFramer.Message)
    func displayAdvertiseError(_ error: NWError)
}

class PeerConnection {
    weak var delegate: PeerConnectionDelegate?
    var connection: NWConnection?
    let endpoint: NWEndpoint?
    let initiatedConnection: Bool

    // Create an outbound connection when the user initiates a game.
    init(endpoint: NWEndpoint, interface _: NWInterface?, delegate: PeerConnectionDelegate) {
        self.delegate = delegate
        self.endpoint = nil
        initiatedConnection = true

        let connection = NWConnection(to: endpoint, using: NWParameters())
        self.connection = connection

        startConnection()
    }

    // Create an outbound connection when the user initiates a game via DeviceDiscoveryUI.
    init(endpoint: NWEndpoint, delegate: PeerConnectionDelegate) {
        self.delegate = delegate
        self.endpoint = endpoint
        initiatedConnection = true

        // Create the NWConnection to the supplied endpoint.
        let connection = NWConnection(to: endpoint, using: applicationServiceParameters())
        self.connection = connection

        startConnection()
    }

    // Handle an inbound connection when the user receives a game request.
    init(connection: NWConnection, delegate: PeerConnectionDelegate) {
        self.delegate = delegate
        endpoint = nil
        self.connection = connection
        initiatedConnection = false

        startConnection()
    }

    // Handle the user exiting the game.
    func cancel() {
        if let connection = connection {
            connection.cancel()
            self.connection = nil
        }
    }

    // Handle starting the peer-to-peer connection for both inbound and outbound connections.
    func startConnection() {
        guard let connection = connection
        else {
            return
        }

        connection.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                print("\(connection) established")

                // When the connection is ready, start receiving messages.
                self?.receiveNextMessage()

                // Notify the delegate that the connection is ready.
                if let delegate = self?.delegate {
                    delegate.connectionReady()
                }
            case let .failed(error):
                print("\(connection) failed with \(error)")

                // Cancel the connection upon a failure.
                connection.cancel()

                if let endpoint = self?.endpoint, let initiated = self?.initiatedConnection,
                   initiated, error == NWError.posix(.ECONNABORTED)
                {
                    // Reconnect if the user suspends the app on the nearby device.
                    let connection = NWConnection(to: endpoint, using: applicationServiceParameters())
                    self?.connection = connection
                    self?.startConnection()
                } else if let delegate = self?.delegate {
                    // Notify the delegate when the connection fails.
                    delegate.connectionFailed()
                }
            default:
                break
            }
        }

        // Start the connection establishment.
        connection.start(queue: .main)
    }

    // Handle sending a "select character" message.
    func selectCharacter(_ character: String) {
        guard let connection = connection
        else {
            return
        }

        // Create a message object to hold the command type.
        let message = NWProtocolFramer.Message(gameMessageType: .selectedCharacter)
        let context = NWConnection.ContentContext(identifier: "SelectCharacter",
                                                  metadata: [message])

        // Send the app content along with the message.
        connection.send(
            content: character.data(using: .utf8),
            contentContext: context,
            isComplete: true,
            completion: .idempotent
        )
    }

    // Handle sending a "move" message.
    func sendMove(_ move: String) {
        guard let connection = connection
        else {
            return
        }

        // Create a message object to hold the command type.
        let message = NWProtocolFramer.Message(gameMessageType: .move)
        let context = NWConnection.ContentContext(identifier: "Move",
                                                  metadata: [message])

        // Send the app content along with the message.
        connection.send(
            content: move.data(using: .utf8),
            contentContext: context,
            isComplete: true,
            completion: .idempotent
        )
    }

    // Receive a message, deliver it to your delegate, and continue receiving more messages.
    func receiveNextMessage() {
        guard let connection = connection
        else {
            return
        }

        connection.receiveMessage { content, context, _, error in
            // Extract your message type from the received context.
            if let gameMessage =
                context?.protocolMetadata(definition: GameProtocol.definition) as? NWProtocolFramer.Message
            {
                self.delegate?.receivedMessage(content: content, message: gameMessage)
            }
            if error == nil {
                // Continue to receive more messages until you receive an error.
                self.receiveNextMessage()
            }
        }
    }
}

var sharedBrowser: PeerBrowser?

// Update the UI when you receive new browser results.
protocol PeerBrowserDelegate: AnyObject {
    func refreshResults(results: Set<NWBrowser.Result>)
    func displayBrowseError(_ error: NWError)
}

class PeerBrowser {
    weak var delegate: PeerBrowserDelegate?
    var browser: NWBrowser?

    // Create a browsing object with a delegate.
    init(delegate: PeerBrowserDelegate) {
        self.delegate = delegate
        // startBrowsing()
    }

    // Start browsing for services.
    func startBrowsing() {
        // Create parameters, and allow browsing over a peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        // Browse for a custom "_tictactoe._tcp" service type.
        let browser = NWBrowser(for: .bonjour(type: "_tictactoe._tcp", domain: nil), using: parameters)
        self.browser = browser
        browser.stateUpdateHandler = { newState in
            switch newState {
            case let .failed(error):
                // Restart the browser if it loses its connection.
                if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_DefunctConnection)) {
                    print("Browser failed with \(error), restarting")
                    browser.cancel()
                    self.startBrowsing()
                } else {
                    print("Browser failed with \(error), stopping")
                    self.delegate?.displayBrowseError(error)
                    browser.cancel()
                }
            case .ready:
                // Post initial results.
                self.delegate?.refreshResults(results: browser.browseResults)
            case .cancelled:
                sharedBrowser = nil
                self.delegate?.refreshResults(results: Set())
            default:
                break
            }
        }

        // When the list of discovered endpoints changes, refresh the delegate.
        browser.browseResultsChangedHandler = { results, _ in
            self.delegate?.refreshResults(results: results)
        }

        // Start browsing and ask for updates on the main queue.
        browser.start(queue: .main)
    }
}
