import System.Environment (getArgs)
import System.Exit
import System.IO
import Control.Exception
import Network
import Control.Concurrent (forkIO)

errorMessage = "Unknown command"
exitMessage = "Client killed service. Byeeeee......"
portNumber = PortNumber 8000 -- :: PortID

main :: IO ()
main = do
    sock <- listenOn portNumber
    putStrLn $ "Server listening on: " ++ show portNumber
    handleConnections sock

handleConnections :: Socket -> IO ()
handleConnections sock = do
    res <- try $ accept sock :: IO (Either IOError (Handle, HostName, PortNumber))
    case res of
        Left _ -> exitSuccess -- we're done, exit(0)
        Right (client, host, port) -> do
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
        "HELO" -> hPutStrLn client $ buildResponse message host port
        otherwise -> putStrLn errorMessage

    hClose client


buildResponse :: String -> HostName -> PortNumber -> String
buildResponse message host port = message ++ "\n" ++
                                  "IP: " ++ host ++ "\n" ++
                                  "Port: " ++ show port ++ "\n" ++
                                  "StudentID: 11420952"
