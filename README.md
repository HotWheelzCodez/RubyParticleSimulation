# Particle Simulation in Ruby

This project is a particle simulation written in Ruby using [Raylib](https://www.raylib.com/) for real-time graphics rendering and [FFmpeg](https://ffmpeg.org/) for exporting frames to a video. Particles are attracted to the user's mouse position, creating a dynamic and visually interesting simulation.

## Features

- Real-time particle simulation with user interaction
- Customizable particle colors, amount, window size, and frame rate via `ps.conf`
- Frame-by-frame recording to PNG and video compilation via FFmpeg
- Toggle recording with the `Spacebar`

## Demo

## Demo

<video src="resources/output.mp4" width="640" controls loop autoplay muted>
  Your browser does not support the video tag.
</video>

## Requirements

- Ruby (recommended version: 3.0 or higher)
- [Raylib Ruby bindings](https://github.com/sol-vin/raylib-ruby)
- FFmpeg (for recording/exporting to video)
- A C compiler and build tools for native extensions (e.g., Xcode CLI on macOS, MSYS2 on Windows)

### Platform-specific notes

- **macOS (Apple Silicon)**: Ensure `DYLD_LIBRARY_PATH` is set correctly. This is handled automatically for `arm64-darwin24` in the code.
- **Windows**: You may need to manually specify the Raylib DLL path.

## Installation

1. **Install dependencies**

   **macOS (using Homebrew):**
   ```sh
   brew install raylib ffmpeg
