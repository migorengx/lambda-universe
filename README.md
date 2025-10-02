# Mountain Hike Map

A **Luau** template for representing a map of a mountain hike. This template can be used to describe waypoints, paths, elevation, and points of interest for a hiking experience.

## Features

- Define waypoints with coordinates and elevation
- Connect waypoints with paths
- Annotate points of interest (POIs)
- Customizable map metadata

## Example

```lua
local MountainHikeMap = {
    name = "Everpeak Trail",
    description = "A scenic mountain hike with breathtaking views.",
    waypoints = {
        { id = 1, name = "Trailhead", position = {x = 0, y = 0}, elevation = 1200 },
        { id = 2, name = "Creek Crossing", position = {x = 50, y = 30}, elevation = 1350 },
        { id = 3, name = "Summit", position = {x = 100, y = 80}, elevation = 2000 },
    },
    paths = {
        { from = 1, to = 2, distance = 1.2 },
        { from = 2, to = 3, distance = 2.5 },
    },
    pointsOfInterest = {
        { waypointId = 2, description = "Freshwater creek, good rest spot." },
        { waypointId = 3, description = "Panoramic mountain views." },
    }
}

return MountainHikeMap
```

## Usage

- Import this template into your Luau project.
- Modify the waypoints, paths, and POIs to match your hike.
- Use the data for visualization or gameplay logic.
