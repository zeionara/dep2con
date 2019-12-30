module Language.Wordd (Wordd (..)) where

import Language.POS (POS (..))
import Data.String.Utils (quoteString)

-- | Wordds are a combination of a textual string and an index into a
--   sentence.
data Wordd
   = Wordd { text   :: String
          , pos    :: POS
          , serial :: Int }
   deriving (Eq, Ord)

instance Show Wordd where
  showsPrec _ (Wordd txt pos ser) =
    showString (show txt) .
    showString "/" .
    showString (show pos) .
    showString "/" .
    shows ser
