Snake
=====
A simple Snake game for DOS written in TASM. Yes, it contains lots of bugs.

How to build
--------------
You need `tasm` and `tlink` to build the game:
```
tasm snake.asm
tlink /t /x snake.obj
```

How to run
------------
You can just run `snake.com`. Also you can use command line options to set
the snake color, the snake length on start and the number of food pieces on the map.

Screenshots
-------------

![Screenshot](screenshots/screenshot-1.png)
![Screenshot](screenshots/screenshot-2.png)
![Screenshot](screenshots/screenshot-3.png)
