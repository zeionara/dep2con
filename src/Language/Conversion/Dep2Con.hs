module Language.Conversion.Dep2Con where

import           Data.List (insert)
import           Language.POS (POS (..), toXP)
import qualified Language.Structure.Constituency as Con
import qualified Language.Structure.Dependency as Dep
import           Language.Wordd (Wordd (Wordd,pos))


-- |Convert dependency structures to constituency structures,
--  ensuring that only the minimal number of projections are made.
collins :: Dep.Tree -> Con.Tree

-- Special case: keep ROOT node intact, making sure it doesn't project to RP.
collins (Dep.Node (Wordd "ROOT" (POS "ROOT") 0) deps)
  = Con.Node (POS "ROOT") (map collins deps)

-- Collins' algorithm:
collins (Dep.Node gov [])
  = Con.Node (pos gov) [Con.Leaf gov]
collins (Dep.Node gov deps)
  = Con.Node xp (insert gov' deps')
  where
    x     = pos gov
    xp    = toXP x
    gov'  = Con.Node x [Con.Leaf gov]
    deps' = map collins deps
