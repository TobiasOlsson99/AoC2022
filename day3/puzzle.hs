import Data.Char(ord, isUpper)
import Data.List(intersect)


priority :: Char -> Int
priority c
    | isUpper c = ord c - ord 'A' + 27
    | otherwise = ord c - ord 'a' + 1

common :: [String] -> Char
--common str = (head . (uncurry intersect)) $ splitAt ((length str) `div` 2) str
common = head . (foldr intersect ['A'..'z'])

splitRucksack :: String -> [String]
splitRucksack str = (\(a,b) -> [a,b]) (splitAt ((length str) `div` 2) str)

splitGroups :: [String] -> [[String]]
splitGroups (a:b:c:xs)  = [a,b,c] : splitGroups xs
splitGroups []          = []
splitGroups xs          = [xs]

puzzle1 :: [String] -> Int
puzzle1 = sum . map (priority . common . splitRucksack)

puzzle2 :: [String] -> Int
puzzle2 = sum . (map (priority . common)) . splitGroups

main :: IO ()
main = 
    do
        filestr <- readFile "input.txt"
        (print . puzzle1 . lines) filestr
        (print . puzzle2 . lines) filestr
