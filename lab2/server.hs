import System.Environment (getArgs)
import System.Exit
import System.IO
import Network
import Control.Concurrent (forkIO)

errorMessage = "Unknown command"
exitMessage = "Terminating..."
portNumber = PortNumber 8000 -- :: PortID

main :: IO ()
main = do
    sock <- listenOn portNumber
    putStrLn $ "Server listening on: " ++ show portNumber
    handleConnections sock

handleConnections :: Socket -> IO ()
handleConnections sock = do
    (client, host, port) <- accept sock -- accept data from network, blocks until we have a connection
    hSetBuffering client NoBuffering
    forkIO $ processRequest sock client host port -- spawn new thread to process request
    handleConnections sock -- recurse (ie. wait for next request)

processRequest :: Socket -> Handle -> HostName -> PortNumber -> IO ()
processRequest sock client host port = do
    message <- hGetLine client

    case head $ words message of
        "KILL_SERVICE" -> do
            hPutStrLn client exitMessage
            sClose sock -- close the socket
            exitSuccess -- equivalent of exit(0) in C
        "HELO" -> hPutStrLn client $ buildResponse message host port
        otherwise -> putStrLn errorMessage

    hClose client


buildResponse :: String -> HostName -> PortNumber -> String
buildResponse message host port = message ++ "\n" ++
                                  "IP: " ++ host ++ "\n" ++
                                  "Port: " ++ show port ++ "\n" ++
                                  "StudentID: 11420952"
