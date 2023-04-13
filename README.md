

- Powerups will spawn according with a frequency parameter in `Powerup.freq` table.
- For every level one of the bricks will be locked and another brick will hold a key secretly, the key will fall down once that brick is destroyed and if the paddle picks it up, the key will be shown in the paddle center.
- Heart powerup will make the player earns a live up to 3.
- Multiple powerup will spawn 2 more balls, only when all balls are lost the player loses a a live.
- Grow and shrink powerups will affect the paddle.

$(luarocks path --bin)

luarocks make --local

npm install

node server.js
