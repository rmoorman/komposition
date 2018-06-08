{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

module FastCut.Video.FFmpegTest where

import           Data.Massiv.Array    as A
import           Graphics.ColorSpace
import           Pipes
import qualified Pipes.Prelude        as Pipes
import           Test.Tasty.Hspec

import           FastCut.Video.FFmpeg

colorImage :: Pixel RGB Word8 -> RGB8Frame
colorImage c = makeArray A.Par (640 :. 480) (const c)

red = PixelRGB 255 0 0
green = PixelRGB 0 255 0

f1, f2 :: RGB8Frame
f1 = colorImage red
f2 = colorImage green

shouldClassifyAs inFrames outFrames =
  Pipes.toList (classifyMovement (Pipes.each inFrames)) `shouldBe` outFrames

spec_classifyMovement = do
  it "discards too short still section" $
    concat [[f1], replicate 5 f2, [f1]] `shouldClassifyAs`
    (Moving f1 : replicate 5 (Moving f2) ++ [Moving f1])
  it "classifies a still section" $
    concat [[f1], replicate 20 f2, [f1]] `shouldClassifyAs`
    concat [[Moving f1], replicate 20 (Still f2), [Moving f1]]
