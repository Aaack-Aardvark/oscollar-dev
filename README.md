### Welcome to OpenCollar!

OpenCollar is a set of LSL scripts and all sort of creative content, such as motions, sounds, graphics and 3D models, which can be used to create role play devices for the metaverse. Traditionally such devices would take form as graphical interface worn on the "HUD" or as fashion accessory worn on the avatar herself.

Punk, goth and fetish collars would be the most popular of those and OpenCollar eventually became the basic standard device for this kind of creative role play amongst adults on Second Life®. OpenCollar is [free software](http://www.gnu.org/philosophy/free-sw.html "What is free software?").

#### Finding your way around this repo

At the moment this repository is separated into resources, source code and web queries. The directory names are self-explanatory and each has a readme attached that tells about specific details. Resource subdirectories inform which file formats we work with and point to other free software that can be used to create such content.

```
./opencollar/

    > res: Resource of creative content.

        > anims: Motions and Animations as .bvh and .avm binaries.
        > models: 3D Models as .dae and .blend binaries.
        > sounds: Sounds as .wav and .aup binaries.
        > textures: Images as .png and .xcf binaries.

    > src: Source code of the OpenCollar role play device.

        > ao: The source code for the animation overrider.
        > collar: The source code for the collar device.
        > installer: The source code for the package manager.
        > remote: The source code for the remote control HUD.
        > spares: Spares and snippets for research and development.

    > web: Web queries.
```

#### License Terms and Addendum

OpenCollar source code and creative resource are covered and protected by strong [copyleft](https://en.wikipedia.org/wiki/Copyleft "What does "copyleft" mean?") licenses.

* LSL scripts are licensed as and must remain under the [GNU General Public License, version 2](http://www.gnu.org/licenses/gpl-2.0).

* Creative content is licensed as and must remain under the [Creative Commons Attribution-ShareAlike 4.0 International Public License](https://creativecommons.org/licenses/by-sa/4.0/).

* Everything else that is shared within the metaverse and where no explicit license was applied is covered by the [License Terms for the OpenCollar Role Play Device](https://raw.githubusercontent.com/OpenCollar/opencollar/master/LICENSE).

**NOTE:** Please make sure that you have read and understood the full legal text of each license if your interest in OpenCollar goes beyond personal use (i.e. commercial redistribution). For human-readable summaries of various licenses, check out [tl;drLegal](https://tldrlegal.com/)

#### OpenSim Porting Information

We target and test for OpenSim 0.8 (stable) and OpenSim 0.9 (unstable, master)

This is the oscollar6 branch, which is a port of OpenCollar [six]  
Check out the oscollar3 branch for a port based on OpenCollar 3.99x

There are some differences between v3 and v6 collars, for instance v6 is much more optimized thanks to certain scripts being in seperate links (which can be optionally invisible, but you do need them seperate).

If you are looking to directly convert or upgrade existing v3 collars for OpenSim, you can use the oscollar3 branch which should be 100% compatible with the last v3 version in Second Life. We haven't made a transmuter tool yet to convert a v3 collar to v6.

A ready made standard OpenCollar for both branches can be be aquired at the OsGrid Sim 'Oaks Woods' in the store IXstatic (hypergrid: hg.osgrid.org:80:Oaks Woods). Creators can use this standard collar as a technical reference for making new products.
