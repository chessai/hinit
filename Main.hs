{-# language
    OverloadedStrings
  , QuasiQuotes
#-}

module Main (main) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import NeatInterpolation (text)
import System.Directory
import System.FilePath
import Control.Monad
import Control.Exception
import System.IO
import Data.Char

main :: IO ()
main = do
  cwd <- getCurrentDirectory
  let projName = takeFileName cwd
  let cabalFilePath = projName ++ ".cabal"
  let setupHsPath = "Setup.hs"
  let changelogPath = "changelog.md"
  let readmePath = "readme.md"
  let licensePath = "LICENSE"
  let projNameT = T.pack projName
  write cabalFilePath $ _CabalFile projNameT
  write setupHsPath _SetupHs
  write changelogPath $ _changelog_md projNameT
  write readmePath $ _readme_md projNameT
  write licensePath _LICENSE
  createDirectoryIfMissing False "app"
  createDirectoryIfMissing False "src"
  write "app/Main.hs" _MainHs
  write ("src/" ++ T.unpack (capFirst projNameT) ++ ".hs") $ _ProjHs projNameT

write :: FilePath -> Text -> IO ()
write path contents = do
  doesExist <- doesFileExist path
  when doesExist $ do
    error $ "filepath: " ++ path ++ " already exists"
  T.writeFile path contents

currentYear :: Text
currentYear = "2020"

minCabalVersion :: Text
minCabalVersion = "2.2"

minBase,maxBase :: Text
minBase = "4.11"
maxBase = "4.14"

capFirst :: Text -> Text
capFirst = T.pack . go . T.unpack
  where
    go [] = []
    go (x:xs) = toUpper x : xs

_ProjHs :: Text -> Text
_ProjHs projName =
  let projNameCapFirst = capFirst projName
  in
  [text|
  module $projNameCapFirst
    (
    ) where
  |]

_MainHs :: Text
_MainHs =
  [text|
  module Main (main) where

  main :: IO ()
  main = pure ()
  |]

_CabalFile :: Text -> Text
_CabalFile projName =
  let projNameCapFirst = capFirst projName
  in
  [text|
  cabal-version: 2.2
  name:
    $projName
  version:
    0.1
  -- synopsis:
  -- description:
  bug-reports:
    https://github.com/chessai/${projName}.git
  license:
    MIT
  license-file:
    LICENSE
  author:
    chessai
  maintainer:
    chessai <chessai1996@gmail.com>
  build-type:
    Simple
  extra-source-files:
    changelog.md
    readme.md

  library
    hs-source-dirs:
      src
    exposed-modules:
      ${projNameCapFirst}
    build-depends:
      , base >= $minBase && < $maxBase
    ghc-options:
      -Wall -O2
    default-language:
      Haskell2010

  executable $projName
    hs-source-dirs:
      app
    main-is:
      Main.hs
    build-depends:
      , base >= $minBase && < $maxBase
    ghc-options:
      -Wall -Werror -O2
    default-language:
      Haskell2010
  |]

_SetupHs :: Text
_SetupHs =
  [text|
  import Distribution.Simple
  main = defaultMain
  |]

_LICENSE :: Text
_LICENSE =
  [text|
  Copyright $currentYear chessai

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  |]

_changelog_md :: Text -> Text
_changelog_md projName =
  [text|
  # Revision history for fun

  ## 0.1.0.0 -- YYYY-mm-dd

  * First version. Released on an unsuspecting world.
  |]

_readme_md :: Text -> Text
_readme_md projName =
  [text|
  # ${projName}
  |]
