# Created by Dustin Bucholtz
# This program is a gravity simulation program to visualize how particles move about a point (being your mouse cursor)

if RUBY_PLATFORM == "arm64-darwin24"
  ENV['DYLD_LIBRARY_PATH'] = '/opt/homebrew/lib' # Assumes it is installed with homebrew
elsif RUBY_PLATFORM == "" # Check windows plateform
  # Load windows raylib path
end

require 'raylib'

Raylib.ffi_lib "#{ENV['DYLD_LIBRARY_PATH']}/libraylib.dylib"
Raylib.setup_raylib_symbols

class Particle
  def initialize(window_width, window_height)
    @random = Random.new
    @position = Raylib::Vector2.create(@random.rand(window_width), @random.rand(window_height))
    @velocity = Raylib::Vector2.create(0.0, 0.0)
    @window_width = window_width
    @window_height = window_height
    @acceleration_strength = 300.0
    @max_speed = 300.0
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
    Raylib.DrawPixel(@position.x.to_i, @position.y.to_i, Raylib::WHITE)
  end
end

def init(amount, window_width, window_height)
  particles = []
  amount.times { particles.append(Particle.new(window_width, window_height)) }
  particles
end

window_width = 800
window_height = 600

amount = 20_000
particles = init(amount, window_width, window_height)

Raylib.InitWindow(window_width, window_height, 'Particle Simulation')

until Raylib.WindowShouldClose
  Raylib.BeginDrawing
  Raylib.ClearBackground(Raylib::BLACK)

  mouse_position = Raylib.GetMousePosition
  delta_time = Raylib.GetFrameTime
  amount.times { |index| particles[index].render mouse_position, delta_time }

  Raylib.EndDrawing
end

Raylib.CloseWindow
