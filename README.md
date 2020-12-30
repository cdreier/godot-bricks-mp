# Godot Bricks Multiplayer

for our `winterplenum` at inovex, i created this small example for Godot Multiplayer in the browser with websockets.

The bricks are persisted with a Go Server in a [boltdb](https://github.com/boltdb/bolt) via [bolthold](https://github.com/timshannon/bolthold) - and additionally alle events in a second db, so you can replay all the brick-events and watch some timelaps :)

TODO: GIF

## controls

WASD  - movement
E     - drop a brick
Q     - toggle camera
SPACE - jump
Click - delete brick

TODO: GIF

## offline

to just test it, there is an offline, non-persistent version, startng when no servers are found to communicate with. 

## deploy

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