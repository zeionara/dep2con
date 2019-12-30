module Language.Structure.Dependency where

import           Data.List (sortBy)
import           Data.Monoid ((<>))
import qualified Data.Tree as Rose
import           Language.Wordd (Wordd(Wordd,serial))


-- |Dependency trees are rose trees with words on both internal nodes
--  and leaves, and label on the links.
data Tree
  = Node
    { govenor    ::  Wordd
    , dependents :: [Tree]
    }
  deriving (Eq, Show)

instance Ord Tree where
  compare x y = compare (leftMostIndex x) (leftMostIndex y)


-- |Get the left-most index from a dependency tree.
leftMostIndex :: Tree -> Int
leftMostIndex (Node (Wordd _ _ i) deps) = minimum (i : map leftMostIndex deps)


-- |Convert the tree to an instance of `Data.Tree` and draw it.
drawTree :: Tree -> String
drawTree ct = Rose.drawTree (go ct)
  where
    go :: Tree -> Rose.Tree String
    go (Node gov deps) = Rose.Node (show gov) (map go deps)


-- |Compute a list of all descendents from a dependency tree.
descendents :: Tree -> [Wordd]
descendents = concatMap go . dependents
  where
    go :: Tree -> [Wordd]
    go (Node gov deps) = gov : concatMap go deps


-- |Enumerate all words in a dependency tree.
allWordds :: Tree -> [Wordd]
allWordds (Node gov deps) = gov : concatMap allWordds deps

-- |Compute the dependencies for a given word.
dependencies :: Wordd -> Tree -> [Wordd]
dependencies _ (Node _ []) = []
dependencies w1 tree@(Node w2 deps)
  | w1  ==  w2 = descendents tree
  | otherwise = concatMap (dependencies w1) deps


-- |Compute the minimum distance from any node in the (sub-)tree to a
--  specific serial. /O(n)/
minDistance :: Int -> Tree -> Int
minDistance i = minimum . map (abs . (i -) . serial) . allWordds


-- |Compare two trees, first by their distance to their governor, and
--  second by their index in the sentence (from the left). /O(n+m)/
nearestThenLeftMost :: Int -> Tree -> Tree -> Ordering
nearestThenLeftMost i x y = byDistanceToGovernor <> byIndex
  where
    byDistanceToGovernor = minDistance i x `compare` minDistance i y
    byIndex              = leftMostIndex x `compare` leftMostIndex y
