# Godot Bricks Multiplayer

For our `winterplenum` at inovex, i created this small example for a dedicated Godot Multiplayer server in the browser with websockets.

There are 3 projects

* The main game at the root of this repository
* The [realtime-server](https://github.com/cdreier/godot-bricks-mp/tree/master/realtime-server), a second Godot project for the dedicated websocket server
* The [brickserver](https://github.com/cdreier/godot-bricks-mp/tree/master/brickserver), written in go for a lightweight persistence and event storage

This go server uses a [boltdb](https://github.com/boltdb/bolt) via [bolthold](https://github.com/timshannon/bolthold) - to persist the current world and additionally persists all events in a second db, so you can replay all the brick-events and watch some timelaps :)

![timelaps](https://github.com/cdreier/godot-bricks-mp/blob/master/demo_gifs/plenum-demo.gif?raw=true)

## Code!

Most of the network code are in the [Connection](https://github.com/cdreier/godot-bricks-mp/blob/master/Connection.gd) [files](https://github.com/cdreier/godot-bricks-mp/blob/master/realtime-server/Connection.gd). The important part is, to set the websocket client and server as network_peer to get everything working with Godots [high level multiplayer API](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)

After learning in [DinoPoker](https://github.com/cdreier/DinoPoker) that a position sync on every frame is working and looks smooth (but kills a small server with a few players), i tested to interpolte the positions [with a timer only 10 times per second](https://github.com/cdreier/godot-bricks-mp/blob/master/Player.gd#L24). Perhaps this can be done a bit more clever?


## Controls

WASD  - movement  
E     - drop a brick  
Q     - toggle camera  
SPACE - jump  
Click - delete brick  
Colorpicker... pick colors

![basics](https://github.com/cdreier/godot-bricks-mp/blob/master/demo_gifs/godot-bricks-basics.gif?raw=true)

With the on/off toggle on the bottom right corner, you can toggle a grid movement where you only move in half-brick steps, so you can better control the position and build acutally something that is more than a big colored pile ;)

## Offline

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