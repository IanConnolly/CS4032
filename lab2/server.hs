import System.Environment (getArgs)
import System.Exit
import System.IO
import Control.Exception
import Network
import Control.Concurrent (forkIO)
import Data.IORef

errorMessage = "Unknown command: "
exitMessage = "Client killed service. Byeeeee......"
maxConnections = 2000 -- some arbritrary constant for exposition


main :: IO ()
main = withSocketsDo $ do
    (portString : _) <- getArgs
    sock <- listenOn $ PortNumber $ fromIntegral (read portString :: Int)
    putStrLn $ "Server listening on port " ++ portString
    sem <- newSem maxConnections -- initialise our semaphore
    handleConnections sock sem -- start server loop

handleConnections :: Socket -> Semaphore -> IO ()
handleConnections sock sem = do
    res <- try $ accept sock :: IO (Either IOError (Handle, HostName, PortNumber))
    case res of
        Left _ -> exitSuccess -- we're done, exit(0)
        Right (client, host, port) -> do
            hSetBuffering client NoBuffering -- don't buffer output to client

            areResourcesAvailable <- pullSem sem -- check if there are enough resources
            if areResourcesAvailable then do
                forkIO $ processRequest sock client host port sem -- spawn new thread to process request
                handleConnections sock sem -- (tail) recurse (ie. wait for next request)
            else do
                hPutStr client "Server overloaded." >> hClose client
                handleConnections sock sem -- (tail) recurse (ie. wait for next request)


processRequest :: Socket -> Handle -> HostName -> PortNumber -> Semaphore -> IO ()
processRequest sock client host port sem = do
    req <- try $ hGetLine client :: IO (Either IOError String)
    case req of
        Left _ -> putStrLn $ serverLog host port "[closed connection without sending data]"
        Right request -> do
            putStrLn $ serverLog host port request -- log

            case head $ words request of -- pattern match the first 'word' in request
                "KILL_SERVICE" -> hPutStr client exitMessage >> sClose sock -- close the socket
                "HELO" -> hPutStr client $ buildResponse request host port
                otherwise -> hPutStr client $ errorMessage ++ request

    hClose client
    signalSem sem -- free up the 'resources' this 'thread' is using


serverLog :: HostName -> PortNumber -> String -> String
serverLog host port message = host ++ ":" ++ show port ++ " -> " ++ message

buildResponse :: String -> HostName -> PortNumber -> String
buildResponse message host port = unlines [message,
                                           "IP: " ++ host,
                                           "Port: " ++ show port] ++
                                           "StudentID: 11420952"

-- semaphore implementation

newtype Semaphore = Semaphore (IORef Int)

newSem :: Int -> IO Semaphore
newSem i = do
    sem <- newIORef i
    return (Semaphore sem)

pullSem :: Semaphore -> IO Bool
pullSem (Semaphore s) = atomicModifyIORef s $ \x -> if x == 0 then
                                                        (x, False)
                                                    else let !z = x - 1 -- make the binding strict
                                                         in (z, True)

signalSem :: Semaphore -> IO ()
signalSem (Semaphore s) = atomicModifyIORef s $ \x -> let !z = x + 1 -- make the binding stricts
                                                      in (z, ())
