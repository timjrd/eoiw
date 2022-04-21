module GetImg (getImg) where

import Data.ByteString.Lazy (ByteString)
import Data.ByteString.Lazy.Char8 (unpack)

import Text.HTML.Scalpel.Core

import Text.Regex.Base
import Text.Regex.TDFA

import Get

regexSrc :: String
regexSrc = "^Download( HI( |\\-)RES)? JPE?G$"

regex :: Regex
regex = makeRegex regexSrc

scraper :: Scraper ByteString [ByteString]
scraper = attrs "href" $ "a" @: ["title" @=~ regex]

getImg :: String -> IO (Maybe ByteString)
getImg url = do
  putStrLn $ "downloading image " ++ url
  imgs <- scrapeGet url scraper
  case imgs of
    Just [img] -> fmap Just $ get $ baseUrl ++ (unpack img)
    _ -> return Nothing
