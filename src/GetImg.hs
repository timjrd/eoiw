module GetImg (getImg) where

import Data.ByteString.Lazy (ByteString)
import Data.ByteString.Lazy.Char8 (unpack)
import Text.HTML.Scalpel.Core

import Get

scraper :: Scraper ByteString ByteString
scraper = attr "href" $ "a" @: ["title" @= "Download HI-RES JPG"]

getImg :: String -> IO (Maybe ByteString)
getImg url = do
  putStrLn $ "downloading image " ++ url
  img <- scrapeGet url scraper
  case img of
    Nothing   -> return Nothing
    Just img' -> fmap Just $ get $ baseUrl ++ (unpack img')
