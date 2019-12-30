{-# LANGUAGE FlexibleContexts #-}

import           Control.Applicative ((<$>),(<*>))
import           Control.Monad (when, forM_)
import           Data.IORef
import qualified Language.Conversion.Con2Bin as Con2Bin
import qualified Language.Conversion.Dep2Bin as Dep2Bin
import qualified Language.Conversion.Dep2Con as Dep2Con
import qualified Language.Structure.Binary             as Bin
import qualified Language.Structure.Constituency       as Con
import qualified Language.Structure.Constituency.Parse as Con
import qualified Language.Structure.Dependency         as Dep
import qualified Language.Structure.Dependency.Parse   as Dep
import           Paths_dep2con (getDataFileName)
import           System.Exit (exitSuccess,exitFailure)
import           System.FilePath.Glob (globDir1, compile)
import           Text.ParserCombinators.UU.BasicInstances (Parser)
import           Text.ParserCombinators.UU.Utils (runParser)

import System.IO hiding (hPutStr, hPutStrLn, hGetLine, hGetContents, putStrLn)
import System.IO.UTF8
import Codec.Binary.UTF8.String (utf8Encode)

pTest :: Parser (Dep.Tree, Con.Tree)
pTest = (,) <$> Dep.pDeps <*> Con.pTree


main :: IO ()
main = do

  testDir   <- getDataFileName "test"
  testFiles <- globDir1 (compile "*.test") testDir
  hasFailed <- newIORef False

  forM_ testFiles $ \testFile -> do

    putStrLn $ "Running test in " ++ testFile
    (input_deps_raw, input_cons) <- runParser "StdIn" pTest <$> readFile testFile

    let input_deps = Dep2Bin.collinsToledo input_deps_raw
    let output_deps = Con2Bin.toledo input_deps_raw input_cons
    let output_cons = Dep2Con.collins input_deps_raw

    when (not (input_deps Bin.==^ output_deps)) $ do

      writeIORef hasFailed True
      System.IO.UTF8.putStrLn ("Input deps: " ++ Con.asMarkdown input_cons)
      --putStrLn ("Actual:   " ++ Con.asMarkdown output_cons)
      --putStrLn ("Expected: " ++ Bin.asMarkdown output_deps)
      System.IO.UTF8.putStrLn ("Output cons:   " ++ Bin.asMarkdown input_deps)

  hasFailed' <- readIORef hasFailed
  if hasFailed'
    then exitFailure
    else exitSuccess
