# Godot Bricks Multiplayer

for our `winterplenum` at inovex, i created this small example for Godot Multiplayer in the browser with websockets.

The bricks are persisted with a Go Server in a [boltdb](https://github.com/boltdb/bolt) via [bolthold](https://github.com/timshannon/bolthold) - and additionally alle events in a second db, so you can replay all the brick-events and watch some timelaps :)

![timelaps](https://github.com/cdreier/godot-bricks-mp/blob/master/demo_gifs/plenum-demo.gif?raw=true)

## code!

most of the network code are in the [Connection](https://github.com/cdreier/godot-bricks-mp/blob/master/Connection.gd) [files](https://github.com/cdreier/godot-bricks-mp/blob/master/realtime-server/Connection.gd). The important part is, to set the websocket client and server as network_peer to get everything working with Godots [high level multiplayer API](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)

After learning in [DinoPoker](https://github.com/cdreier/DinoPoker) that a position sync on every frame is working and looks smooth (but kills the small server with a few players), i tested to interpolte the positions [with a timer only 10 times per second](https://github.com/cdreier/godot-bricks-mp/blob/master/Player.gd#L24). Perhaps this can be done a bit more clever?


## controls

WASD  - movement  
E     - drop a brick  
Q     - toggle camera  
SPACE - jump  
Click - delete brick  

![basics](https://github.com/cdreier/godot-bricks-mp/blob/master/demo_gifs/godot-bricks-basics.gif?raw=true)

## offline

to just test it, there is an offline, non-persistent version, startng when no servers are found to communicate with. 

## WIP: deploy

not yet dockerized...

```yaml
version: '3.2'

services:

  server:
    image: drailing/godot-bricks-mp-rt:latest
    networks: 
      - traefik-overlay
      - storage-net
    environment:
      - BRICK_SERVER=http://brickserver:8080
        
  brickserver:
    image: drailing/godot-bricks-mp-brickserver:latest
    volumes:
      - brickserver-data:/app/data
    networks: 
      - storage-net

  web:
    image: this-is-up-to-you

networks: 
  traefik-overlay:
    external: true
  storage-net:
  
volumes:
  brickserver-data:
    external: true
```