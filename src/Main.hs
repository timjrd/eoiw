import System.FilePath
import System.Directory
import System.Environment
import Data.List
import Data.Char
import qualified Data.ByteString.Lazy as BS
import System.Random

import System.Random.Shuffle
import Data.List.Split

import Codec.Picture

import GetDB
import GetImg

minWidth  = 3440
minHeight = 1440

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
           , ("all"   , all_  )
           , ("pick"  , pick  ) ]

dbFile = do
  home <- getHomeDirectory
  return $ home </> ".eoiwdb"

imgFile = do
  home <- getHomeDirectory
  return $ home </> ".eoiw.jpg"

update :: IO ()
update = do
  putStrLn "scraping image list"
  db   <- getDB
  file <- dbFile
  putStrLn $ "writing image list to file " ++ file
  writeFile file $ unlines db

all_ :: IO ()
all_ =
  let
    isClean x = (x >= 'a' && x <= 'z') || (x >= '0' && x <= '9')
    cleanOrSpace x = let y = toLower x in if isClean y then y else ' '
    pad x = replicate (4 - length x) '0' ++ x
    urlToFilename i url =
      let
        name = intercalate "-"
          $ words
          $ map cleanOrSpace
          $ last
          $ splitOn "/" url
      in
        (pad $ show i) ++ "_" ++ name ++ ".jpg"
  in do
    urls <- shuffledImgUrls
    tryUrls urls False $ \i url dat ->
      writeImgToFile (urlToFilename i url) dat

pick :: IO ()
pick = do
  file <- imgFile
  urls <- shuffledImgUrls
  tryUrls urls True $ \_ _ dat ->
    writeImgToFile file dat

writeImgToFile :: FilePath -> BS.ByteString -> IO ()
writeImgToFile file dat = do
  let tmp = file ++ ".tmp"
  putStrLn $ "writing image to file " ++ file
  BS.writeFile tmp dat
  renameFile   tmp file

tryUrls :: [String] -> Bool -> (Int -> String -> BS.ByteString -> IO ()) -> IO ()
tryUrls urls stop f = try 1 urls
  where
    try _ [] = return ()
    try i (x:xs) = do
      mdat <- getImg x
      case mdat of
        Nothing -> try i xs
        Just dat ->
          if not $ isLargeEnough dat
          then try i xs
          else do
            f i x dat
            if stop
              then return ()
              else try (i+1) xs

isLargeEnough :: BS.ByteString -> Bool
isLargeEnough dat =
  case decodeImage $ BS.toStrict dat of
    Left _ -> False
    Right img ->
      let
        w = dynamicMap imageWidth img
        h = dynamicMap imageHeight img
      in
        w >= minWidth &&
        h >= minHeight

shuffledImgUrls :: IO [String]
shuffledImgUrls = do
  db <- dbFile
  images <- readFile db
  shuffleM $ lines images
