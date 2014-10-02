import Network.Socket
import System.Exit
import System.IO
import Control.Monad
import Control.Exception

path     = "GET /echo.php?message="
protocol = "HTTP/1.1\r\n"
headers  = "Host: localhost\r\n" ++
           "Connection: close\r\n" ++
           "User-Agent: MyAwesomeUserAgent/1.0.0\r\n" ++
           "Accept-Encoding: gzip\r\n" ++
           "Accept-Charset: ISO-8859-1,UTF-8;q=0.7,*;q=0.7\r\n" ++
           "Cache-Control: no-cache\r\n\n"


localhost = 0 -- localhost's IP addr is 0.0.0.0 aka. 0
port = 8000
chunkSize = 4096

main :: IO ()
main = do
    socket <- createTCPSocket
    connect socket (SockAddrInet port localhost)
    query <- prompt "Enter string to uppercase: "
    send socket (path ++ query ++ " " ++ protocol ++ headers)
    forever $ do
        res <- try $ recv socket chunkSize :: IO (Either IOError String)
        case res of
            Left _ -> exitSuccess -- recv throws IOError on EOF
            Right s -> putStr s


createTCPSocket :: IO Socket
createTCPSocket = socket AF_INET Stream defaultProtocol

prompt :: String -> IO String
prompt p = do
    putStr p
    hFlush stdout -- else the putStr will be buffered & not output til later
    s <- getLine
    putStr "\n"
    return s
