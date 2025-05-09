# Created by Dustin Bucholtz
# This program is a particle simulation program to visualize how particles move about a point (being your mouse cursor)

if RUBY_PLATFORM == "arm64-darwin24"
  ENV['DYLD_LIBRARY_PATH'] = '/opt/homebrew/lib' # Assumes it is installed with homebrew
elsif RUBY_PLATFORM == "" # Check windows platform
  # Load windows raylib path
end

require 'raylib'

Raylib.ffi_lib "#{ENV['DYLD_LIBRARY_PATH']}/libraylib.dylib"
Raylib.setup_raylib_symbols

Dir.mkdir('frames') unless Dir.exist?('frames')
File.delete('output.mp4') if File.exist?('output.mp4')

class Particle
  def initialize(window_width, window_height, particle_color)
    @random = Random.new
    @position = Raylib::Vector2.create(@random.rand(window_width), @random.rand(window_height))
    @velocity = Raylib::Vector2.create(0.0, 0.0)
    @window_width = window_width
    @window_height = window_height
    @acceleration_strength = 300.0
    @max_speed = 300.0
    @particle_color = particle_color
  end

  def update(mouse_position, delta_time)
    dx = mouse_position.x - @position.x
    dy = mouse_position.y - @position.y

    distance = Math.sqrt(dx * dx + dy * dy)
    if distance.positive?
      direction_x = dx / distance
      direction_y = dy / distance
    else
      direction_x = 0
      direction_y = 0
    end

    acceleration_x = direction_x * @acceleration_strength * delta_time
    acceleration_y = direction_y * @acceleration_strength * delta_time

    @velocity.x += acceleration_x
    @velocity.y += acceleration_y

    speed = Math.sqrt(@velocity.x**2 + @velocity.y**2)
    if speed > @max_speed
      scale = @max_speed / speed
      @velocity.x *= scale
      @velocity.y *= scale
    end

    @position.x += @velocity.x * delta_time
    @position.y += @velocity.y * delta_time
  end

  def render(mouse_position, delta_time)
    update mouse_position, delta_time
    Raylib.DrawPixel(@position.x.to_i, @position.y.to_i, @particle_color)
  end
end

window_width = 800
window_height = 600
frame_rate = 60
video_frame_rate = 30

background_color = Raylib::BLACK
particle_color = Raylib::WHITE

amount = 20_000

file = File.new('ps.conf', 'r')
if file
  while (line = file.gets)
    parts = line.split('=')
    key = parts[0].strip

    case key
    when 'background_color'
      background_color = Raylib.const_get(parts[1].strip!.upcase)
    when 'particle_color'
      particle_color = Raylib.const_get(parts[1].strip!.upcase)
    when 'particle_amount'
      amount = parts[1].strip.to_i
    when 'window_width'
      window_width = parts[1].strip.to_i
    when 'window_height'
      window_height = parts[1].strip.to_i
    when 'frame_rate'
      frame_rate = parts[1].strip.to_i
    when 'video_frame_rate'
      video_frame_rate = parts[1].strip.to_i
    end
  end
end

def init(amount, window_width, window_height, particle_color)
  particles = []
  amount.times { particles.append(Particle.new(window_width, window_height, particle_color)) }
  particles
end

particles = init(amount, window_width, window_height, particle_color)

Raylib.InitWindow(window_width, window_height, 'Particle Simulation')

recording = false
frame_count = 0
render_texture = nil

until Raylib.WindowShouldClose
  Raylib.SetTargetFPS frame_rate

  if Raylib.IsKeyPressed(Raylib::KEY_SPACE)
    recording = !recording
    if recording && render_texture.nil?
      render_texture = Raylib.LoadRenderTexture(window_width, window_height)
    end
  end

  if recording
    Raylib.BeginTextureMode(render_texture)
  end

  Raylib.BeginDrawing
  Raylib.ClearBackground(background_color)
  mouse_position = Raylib.GetMousePosition
  delta_time = Raylib.GetFrameTime
  amount.times { |index| particles[index].render mouse_position, delta_time }
  Raylib.EndDrawing

  if recording
    Raylib.EndTextureMode

    image = Raylib.LoadImageFromTexture(render_texture.texture)
    Raylib.ImageFlipVertical(image)
    filename = "frames/frame_#{frame_count.to_s.rjust(4, '0')}.png"
    Raylib.ExportImage(image, filename)
    Raylib.UnloadImage(image)
    frame_count += 1

    Raylib.BeginDrawing
    Raylib.ClearBackground(Raylib::BLACK)
    Raylib.DrawTexture(render_texture.texture, 0, 0, Raylib::WHITE)
    Raylib.DrawText('Recording', 20, 20, 20, Raylib::RED)
    Raylib.EndDrawing
  end
end

Raylib.UnloadRenderTexture(render_texture) if render_texture
Raylib.CloseWindow

system("ffmpeg -framerate #{video_frame_rate} -i frames/frame_%04d.png -c:v libx264 -pix_fmt yuv420p output.mp4")
Dir.glob('frames/*.png').each { |file| File.delete(file) }
