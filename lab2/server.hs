import System.Environment (getArgs)
import System.Exit
import System.IO
import Network
import Control.Concurrent (forkIO)

errorMessage = "Unknown command"
exitMessage = "Terminating..."

main :: IO ()
main = do
    args <- getArgs
    sock <- listenOn $ PortNumber $ fromIntegral $ read $ head args
    putStrLn $ "Server listening on: " ++ (head args)
    handleConnections sock

handleConnections :: Socket -> IO ()
handleConnections sock = do
    (client, host, port) <- accept sock -- accept data from network, blocks until we have a connection
    hSetBuffering client NoBuffering
    forkIO $ processRequest sock client host port -- spawn new thread to process request
    handleConnections sock -- recurse

processRequest :: Socket -> Handle -> HostName -> PortNumber -> IO ()
processRequest sock client host port = do
    message <- hGetLine client

    case (head $ words $ message) of
        "KILL_SERVICE" -> do
            hPutStrLn client exitMessage
            sClose sock
            exitSuccess
        "HELO" -> do
            hPutStrLn client $ buildResponse message host port
        otherwise -> putStrLn errorMessage

    hClose client


buildResponse :: String -> HostName -> PortNumber -> String
buildResponse message host port = message ++
                                  "IP: " ++ host ++ "\n" ++
                                  "Port: " ++ (show port) ++ "\n" ++
                                  "StudentID: 11420952"
