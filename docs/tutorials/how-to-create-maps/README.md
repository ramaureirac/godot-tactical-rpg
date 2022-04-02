#### About

In this README you will learn how to create tactical maps in Blender and how to import them into Godot Engine. This project include a simple autodetection system which will allow you into create maps as fast as posible, but make sure to follow each step of this guide.

#### Requirements

- [Blender](https://www.blender.org/)
- Little bit of Blender Experience
- [Godot Blender Exporter](https://github.com/godotengine/godot-blender-exporter)

#### Create a map

First of all let's create a new blender project an remove all the objects with "A", then "X".
![preview](./img/1.png)

Now, lets create a new cube with "Shift+A" and select Mesh > Cube. 
![preview](./img/2.png)

Make sure its size is 1m
![preview](./img/3.png)

From edit mode (hit "Tab key") use "S" to activate scale mode. Click anywhere to cancel and manually set the size from the menu.
![preview](./img/4.png)

In my case will go for a simple 5x5 grid
![preview](./img/5.png)

Lets switch to "Face select" from the menu above
![preview](./img/6.png)

And lets move to the bottom view by clicking the -Z axis at the top right corner
![preview](./img/7.png)

Select the bottom face and then "X" to remove it
![preview](./img/8.png)

You will now have an empy mesh
![preview](./img/9.png)

Create a grid by adding some cuts with "Ctrl+R". 
![preview](./img/10.png)

As I crated a 5x5 map I must add 4 cuts on each side of the mesh in order to mantain the ratio
![preview](./img/11.png)

Now you will be able to modify your map and even add some textures to it
![preview](./img/12.png)

#### Create tiles

Go to the top view by using the Z axis in the top right corner
![preview](./img/13.png)

And select all "visible" faces from the top view
![preview](./img/14.png)

As you can see those are the surface and walkeable tiles for the in game characters
![preview](./img/15.png)

Hit "Shift+D" in order to duplicate, you should be able to move the surface of the mesh but don't do it, this is just an example of what you should see.
![preview](./img/16.png)

Now use "P" and select Selection to separate the "walkeable tiles" from the mesh
![preview](./img/17.png)

As you can se we now have two objects "Cube" and "Cube.001"
![preview](./img/18.png)

Lets rename them as "Terrain" and "Tile"
![preview](./img/19.png)

I will also hide Terrain cause I will not be using it for a while
![preview](./img/20.png)

Select Tile and switch into Edit mode
![preview](./img/21.png)

Go to Mesh > Split > Face by edges
![preview](./img/22.png)

By doing this each tile will be isolated from the rest
![preview](./img/23.png)

Use "P" again to separete by "Loose parts"
![preview](./img/24.png)

Now each tile will be an independent object
![preview](./img/25.png)

From object mode, select all tiles. Then go to Object > Set Origin > Origin to geometry
![preview](./img/26.png)

Now each tile is independent and has its own origin
![preview](./img/27.png)

Select all tiles, hit "Ctrl+A" and select Scale the enter to confirm. This will do apparently but will reset each tile into a 1x1 size insted the 5x5 that we set in first place.
![preview](./img/28.png)

You can check those values in the expanding the right menu
![preview](./img/29.png)

Go to the UV editing map and select all tiles, then "U" to unwrap.
![preview](./img/30.png)

Make sure all the tiles are visible into the left side viewport
![preview](./img/31.png)

Select all tiles
![preview](./img/32.png)

Go to UV > Reset in order to reset their UV projections
![preview](./img/33.png)

Make sure every tile is using the full size of the UV space
![preview](./img/34.png)

#### Export into Godot

Make Terrain visible again
![preview](./img/35.png)

Export as .escn
![preview](./img/36.png)

Save the blender escene into the root of your project
![preview](./img/37.png)

Open it from Godot Editor
![preview](./img/38.png)

Duplicate the "test_arena" template
![preview](./img/39.png)

Give it a new name
![preview](./img/40.png)

Start moving all the tiles inside the "Tiles" spatial node. First I suggest to remove old tiles
![preview](./img/45.png)
![preview](./img/46.png)
![preview](./img/47.png)

And then copy and paste from the exported scene into the new one
![preview](./img/48.png)
![preview](./img/49.png)

Do the same with the terrain mesh
![preview](./img/50.png)
![preview](./img/51.png)
![preview](./img/52.png)
![preview](./img/53.png)

Make sure to move down the terrain mesh (but just a little)
![preview](./img/54.png)

Lets now duplicate the "test_level" template 
![preview](./img/56.png)
![preview](./img/57.png)

And replace the Arena node for the new one that we already configured
![preview](./img/58.png)
![preview](./img/59.png)
![preview](./img/60.png)

Make sure to add and adjust as many characters as you need
![preview](./img/61.png)

Now you are able to delete the exported .escn from your project and close its viewport tab
![preview](./img/62.png)
![preview](./img/63.png)

Test your new level
![preview](./img/64.png)




















































