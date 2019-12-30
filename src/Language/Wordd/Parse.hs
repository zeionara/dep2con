{-# LANGUAGE FlexibleContexts #-}
module Language.Wordd.Parse (pWordd) where

import Language.POS.Parse (pPOS)
import Language.Wordd (Wordd(..))
import Text.ParserCombinators.UU ((<?>))
import Text.ParserCombinators.UU.BasicInstances (Parser)
import Text.ParserCombinators.UU.Idioms (iI,Ii (..))
import Text.ParserCombinators.UU.Utils (pQuotedString,pInteger)

-- | Parser for words.
pWordd :: Parser Wordd
pWordd = iI Wordd pQuotedString '/' pPOS '/' pInteger Ii <?> "Wordd"
