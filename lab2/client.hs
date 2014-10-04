import Network
import Control.Monad
import System.IO
import System.Exit
import System.Environment



main :: IO ()
main = do
    (host : portString : _) <- getArgs
    let port = PortNumber $ fromIntegral (read portString :: Int)
    sendMessages host port


sendMessages :: HostName -> PortID -> IO ()
sendMessages host port = do
    sock <- connectTo host port
    message <- prompt "Enter message to send: "
    hPutStrLn sock message
    resp <- hGetContents sock
    putStrLn resp
    when (head (words message) == "KILL_SERVICE") exitSuccess
    sendMessages host port


prompt :: String -> IO String
prompt p = do
    putStr p
    hFlush stdout -- else the putStr will be buffered & not output til later
    s <- getLine
    putStr "\n"
    return s
