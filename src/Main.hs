import System.FilePath
import System.Directory
import System.Environment
import Data.List
import qualified Data.ByteString.Lazy as BS
import System.Random

import GetDB
import GetImg

main :: IO ()
main = do
  args <- getArgs
  if length args /= 1
  then usage
  else case lookup (head args) commands of
    Nothing -> usage
    Just f  -> f
  
usage :: IO ()
usage = do
  prog <- getProgName
  let cmds = intercalate "|" $ map fst commands
  putStrLn $ "usage: " ++ prog ++ " " ++ cmds

commands :: [(String, IO ())]
commands = [ ("update", update)
           , ("pick"  , pick  ) ]

dbFile = do
  home <- getHomeDirectory
  return $ home </> ".eoiwdb"

imgFile = do
  home <- getHomeDirectory
  return $ home </> ".eoiw.jpg"

tmpFile = do
  home <- getHomeDirectory
  return $ home </> ".eoiw.jpg.tmp"

update :: IO ()
update = do
  putStrLn "scraping image list"
  db   <- getDB
  file <- dbFile
  putStrLn $ "writing image list to file " ++ file
  writeFile file $ unlines db
  
pick :: IO ()
pick = do
  db     <- dbFile
  img    <- imgFile
  tmp    <- tmpFile
  images <- lines <$> readFile db
  i      <- getStdRandom (randomR (0, length images - 1))
  let url = images !! i
  
  putStrLn $ "downloading image " ++ url
  dat    <- getImg url

  putStrLn $ "writing image to file " ++ img
  BS.writeFile tmp dat
  renameFile tmp img
