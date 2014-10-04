import System.Environment (getArgs)
import System.Exit
import System.IO
import Control.Exception
import Network
import Control.Concurrent (forkIO)

errorMessage = "Unknown command: "
exitMessage = "Client killed service. Byeeeee......"

main :: IO ()
main = do
    (portString : _) <- getArgs
    sock <- listenOn $ PortNumber $ fromIntegral (read portString :: Int)
    putStrLn $ "Server listening on port " ++ portString
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
    req <- try $ hGetLine client :: IO (Either IOError String)
    case req of
        Left _ -> putStrLn $ host ++ ":" ++ show port ++ " closed connection without sending data"
        Right request -> do
            putStrLn $ host ++ ":" ++ show port ++ " -> " ++ request -- log
            case head $ words request of -- pattern match first 'word' in request
                "KILL_SERVICE" -> hPutStr client exitMessage >> sClose sock -- close the socket
                "HELO" -> hPutStr client $ buildResponse request host port
                otherwise -> hPutStr client $ errorMessage ++ request

    hClose client

buildResponse :: String -> HostName -> PortNumber -> String
buildResponse message host port = unlines [message,
                                           "IP: " ++ host,
                                           "Port: " ++ show port] ++
                                           "StudentID: 11420952"
