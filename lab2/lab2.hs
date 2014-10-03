import System.Environment (getArgs)
import System.IO
import Network
import Control.Concurrent


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
    forkIO $ processRequest client -- spawn new thread to process request
    handleConnections sock host port -- recurse

processRequest :: Handle -> HostName -> PortNumber -> IO ()
processRequest client = do
    -- TODO
