package = "cs50-breakout"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/diegovinie/cs50-breakout.git"
}
description = {
   summary = "freq` table.",
   detailed = [[
- Powerups will spawn according with a frequency parameter in `Powerup.freq` table.
- For every level one of the bricks will be locked and another brick will hold a key secretly, the key will fall down once that brick is destroyed and if the paddle picks it up, the key will be shown in the paddle center.
- Heart powerup will make the player earns a live up to 3.
- Multiple powerup will spawn 2 more balls, only when all balls are lost the player loses a a live.
- Grow and shrink powerups will affect the paddle.]],
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      Ball = "src/Ball.lua",
      Brick = "src/Brick.lua",
      Dependencies = "src/Dependencies.lua",
      LevelMaker = "src/LevelMaker.lua",
      Paddle = "src/Paddle.lua",
      Powerup = "src/Powerup.lua",
      StateMachine = "src/StateMachine.lua",
      Util = "src/Util.lua",
      constants = "src/constants.lua",
      ["states.BaseState"] = "src/states/BaseState.lua",
      ["states.EnterHighScoreState"] = "src/states/EnterHighScoreState.lua",
      ["states.GameOverState"] = "src/states/GameOverState.lua",
      ["states.HighScoreState"] = "src/states/HighScoreState.lua",
      ["states.PaddleSelectState"] = "src/states/PaddleSelectState.lua",
      ["states.PlayState"] = "src/states/PlayState.lua",
      ["states.ServeState"] = "src/states/ServeState.lua",
      ["states.StartState"] = "src/states/StartState.lua",
      ["states.VictoryState"] = "src/states/VictoryState.lua"
   }
}
