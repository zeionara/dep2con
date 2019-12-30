{-# LANGUAGE RankNTypes, FlexibleContexts #-}
module Language.Structure.Dependency.Parse (pTree,pDeps) where

import           Control.Applicative ((<|>),(<*>),(<*),(*>))
import           Data.Char (isSpace)
import           Data.List (sort)
import           Language.POS (POS(POS))
import           Language.Structure.Dependency (Tree(..))
import           Language.Wordd (Wordd(Wordd))
import qualified Language.Wordd.Parse as W (pWordd)
import           Text.ParserCombinators.UU ((<$>),pSome,pMany,pList1Sep)
import           Text.ParserCombinators.UU.BasicInstances (Parser,pSym,pMunch)
import           Text.ParserCombinators.UU.Utils (lexeme,pParens,pNatural,pLetter,pComma)


pTree :: Parser Tree
pTree = lexeme (pLeaf <|> pNode)
  where
    pLeaf :: Parser Tree
    pLeaf = Node <$> W.pWordd <*> return []
    pNode :: Parser Tree
    pNode = pParens (Node <$> W.pWordd <*> pMany pTree)


pDeps :: Parser Tree
pDeps = do pos     <- lexeme pInit
           depList <- pDepList pos
           return (depsToTree depList root)
  where
    pInit :: Parser (Int -> POS)
    pInit = (\tags serial -> tags !! (serial - 1)) <$> pPhrase
      where
        pWordd   = pMunch (/='/')
        pPOS    = POS <$> pMunch (not . isSpace)
        pPhrase = pList1Sep (pSym ' ') (pWordd *> pSym '/' *> pPOS)

    pDepList :: (Int -> POS) -> Parser [(Wordd, Wordd)]
    pDepList pos = pSome (lexeme pDep)
      where
        pDep   :: Parser (Wordd, Wordd)
        pDep   = pLabel *> pParens ((,) <$> pWordd <* pComma <*> pWordd)
          where
            pLabel             = pSome pLetter
            mkWordd text serial = Wordd text (pos serial) serial
            pWordd              = mkWordd <$> pMunch (/='-') <* pSym '-' <*> pNatural

    depsToTree :: [(Wordd, Wordd)] -> Wordd -> Tree
    depsToTree deps word
      = Node word (sort . map (depsToTree deps . snd) . depsOf $ word)
      where
        depsOf :: Wordd -> [(Wordd, Wordd)]
        depsOf (Wordd _ _ i) = filter (\ (Wordd _ _ j , _) -> i == j) deps

    root :: Wordd
    root = Wordd "ROOT" (POS "ROOT") 0
