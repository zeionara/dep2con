{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_dep2con (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/dima/.cabal/bin"
libdir     = "/home/dima/.cabal/lib/x86_64-linux-ghc-8.0.1/dep2con-0.1.0.0-inplace-dep2con"
dynlibdir  = "/home/dima/.cabal/lib/x86_64-linux-ghc-8.0.1"
datadir    = "/home/dima/.cabal/share/x86_64-linux-ghc-8.0.1/dep2con-0.1.0.0"
libexecdir = "/home/dima/.cabal/libexec/x86_64-linux-ghc-8.0.1/dep2con-0.1.0.0"
sysconfdir = "/home/dima/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "dep2con_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "dep2con_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "dep2con_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "dep2con_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "dep2con_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "dep2con_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
