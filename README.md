# Blades in Godot
An open-source reimplementation of the Xbox 360 'Blades' Dashboard in Godot, with a focus on accuracy to the original dashboard, portability, and customizability through JSON.

This project is in early active development. As such, beware that bugs, issues, crashes, and unfinished features are to be expected. The project is a huge spaghetti mess at the moment, and a large part of current development is focused on righting said spaghetti.

To run: For now, import the project into Godot 4.4, open it, and click the run button in the editor.
In the future, there will likely be binaries.

Currently, the only officially supported platform is Windows. Depending on the systems that are available to those working on the project at any given point, this can change.
Additionally, as Godot is widely portable, ports to other platforms (Linux, Mac, Android, Web) should be fairly simple for those who wish to have them.

## Roadmap:
### Current goals:
- Configure .JSON implementation for each object (Blades, Menus, Animations?)
- Design and implement new UI objects for tab-style menus
- Design and implement all second-order menus (Such as those from the settings menu)
- Implement support for infinite background gradients

### Distant future:
- Redraw all third-party assets (Namely, those from XBMC360)
- Enable starting games and programs
- User-configurable games and program lists
- Implement support for Steam (Gathering games lists, gathering achievement information, social aspects?)
- Social support? (Discord, etc?)