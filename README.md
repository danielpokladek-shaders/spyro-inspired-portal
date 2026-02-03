# Spyro Inspired Portal

My attempt at re-creating the portals from Spyro: Reignited Trilogy.

https://github.com/user-attachments/assets/f8bcdb75-ba66-40ef-b83a-85c552825871

See this [blog post](https://www.danielpokladek.me/posts/shaders/2026/spyro-inspired-portal/), for a more in-depth breakdown of this shader.

## Overview

This shader uses a secondary camera, which render to render texture, in combination with view space vertex positions to achieve the background look. UVs of the background are then further distorted using a simple scrolling noise pattern, and glow outline is achieved using depth texture, HDR color, and Unity's URP bloom.

## Specs

- Unity: **6000.3.5f2**
- Render Pipeline: **Universal Render Pipeline (URP)**

## License

Licensed under MIT unless otherwise specified - see [LICENSE](./LICENSE) for more information.

## Acknowledgements

Kenney Prototype Textures - https://www.kenney.nl/assets/prototype-textures

Depth by Cyanilux - https://www.cyanilux.com/tutorials/depth/

Portals Video by Sebastian Lague - https://www.youtube.com/watch?v=cWpFZbjtSQg

Portal Model by losdayver - https://sketchfab.com/3d-models/ancient-portal-frame-934bbd85eb4041128a1fa4cde8ac0ea9
