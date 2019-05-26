module GetDB (getDB) where

import Data.Function ((&))
import Control.Monad
import Data.ByteString.Lazy (ByteString)
import Data.ByteString.Lazy.Char8 (unpack)
import Text.HTML.Scalpel.Core

import Get

mkUrl :: Int -> URL
mkUrl offset = baseUrl ++ "/spaceinimages/Sets/Earth_observation_image_of_the_week/(offset)/" ++ show offset ++ "/(sortBy)/published"

scraper :: Scraper ByteString [ByteString]
scraper = attrs "href" $
  AnyTag @: [hasClass "psr_results"] // "a"

scrapePage :: Int -> IO [URL]
scrapePage offset = do
  r <- scrapeGet (mkUrl offset) scraper
  
  let page = case r of
        Just r' -> map ((baseUrl++) . unpack) r'
        Nothing -> []
        
  zip [offset..] page & forM_ $ \(i,url) -> do
    putStr $ show i ++ " "
    putStrLn url

  return page

scrapeAll :: Int -> IO [URL]
scrapeAll offset = do
  page <- scrapePage offset
  if null page
    then return []
    else do
      next <- scrapeAll $ offset + length page
      return $ page ++ next

getDB :: IO [URL]
getDB = scrapeAll 0
