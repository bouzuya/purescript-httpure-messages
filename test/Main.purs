module Test.Main where

import Prelude

import Effect (Effect)
import Test.Router as Router
import Test.Unit.Main as TestUnitMain

main :: Effect Unit
main = TestUnitMain.runTest do
  Router.tests
