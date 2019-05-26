module GetImg (getImg) where

import Data.ByteString.Lazy (ByteString)
import Data.ByteString.Lazy.Char8 (unpack)
import Text.HTML.Scalpel.Core

import Get

scraper :: Scraper ByteString ByteString
scraper = attr "href" $ "a" @: [hasClass "d-jpg-hi"]

getImg :: String -> IO ByteString
getImg url = do
  img <- scrapeGet url scraper
  case img of
    Nothing   -> error "unable to scrape image file url"
    Just img' -> get $ baseUrl ++ (unpack img')
