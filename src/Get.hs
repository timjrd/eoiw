module Get where

import Data.ByteString.Lazy (ByteString)
import Network.HTTP.Client
import Network.HTTP.Client.TLS
import Text.HTML.Scalpel.Core

type URL = String

baseUrl = "https://www.esa.int"

get :: URL -> IO ByteString
get url = do
  manager  <- newManager tlsManagerSettings
  request  <- parseRequest url
  response <- httpLbs request manager
  return $ responseBody response

scrapeGet :: URL -> Scraper ByteString a -> IO (Maybe a)
scrapeGet url scraper = do
  body <- get url
  return $ scrapeStringLike body scraper
