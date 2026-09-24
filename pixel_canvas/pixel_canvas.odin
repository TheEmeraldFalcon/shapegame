
package pxcv

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "vendor:raylib"

Outline_Kernel_Positions :: enum {
	Top_Left,
	Top_Center,
	Top_Right,
	Center_Left,
	Center_Right,
	Bottom_Left,
	Bottom_Center,
	Bottom_Right,
}

Outline_Kernel_Set :: bit_set[Outline_Kernel_Positions]

Vector :: [2]i32

Canvas :: struct {
	width : int,
	height : int,

	clear_color: raylib.Color,

	image : raylib.Image,
	texture : raylib.Texture,

	screen_coords : raylib.Vector2,

	screen_scale : f32
}

Outline :: struct {
	width : int,
	color : raylib.Color,
	
	kernel : Outline_Kernel_Positions
}

Shape :: struct {
	outline : Outline,

	color : raylib.Color
}

Shape_Ellipse :: struct {
	using shape: Shape,

	position : Vector,
	size : Vector,
}

Shape_Rectangle :: struct {
	using shape: Shape,

	position : Vector,
	size : Vector,
}

Shape_Line :: struct {
	using shape: Shape,

	point1 : Vector,
	point2 : Vector,

	width : int,

	// If 0, don't round corners.
	// If -1, round corners fully.
	// Else, round by given pixels.
	point_radius : int
}

Shape_Polygon :: struct {
	using shape: Shape,

	points : [dynamic]Vector,

	// If 0, don't round corners.
	// If -1, round corners fully.
	// Else, round by given pixels.
	point_radius : int
}

// TODO: Consider REFACTOR
//  Have draw_{shape} function, which uses recursion to draw outline,
//  then call that from draw_{shape}s function.
// TODO: Another idea
//  Let the user submit multiple shapes, THEN draw outline around those.

draw_ellipses :: proc(canvas: ^Canvas, shapes : [dynamic]Shape_Ellipse) {
	write_pixels :: proc(canvas: ^Canvas, shape: Shape_Ellipse) {
		center_x := shape.position.x
		center_y := shape.position.y
		radius_h := shape.size.x
		radius_v := shape.size.y

		for y in center_y - radius_v..=center_y + radius_v {
			for x in center_x - radius_h..=center_x + radius_h {
				(x >= 0 && x < canvas.image.width && y >= 0 && y < canvas.image.height) or_continue

				dx := f32(x - center_x) / f32(radius_h)
				dy := f32(y - center_y) / f32(radius_v)
				// Slightly above 1.0 to flatten circle ends a little.
				if dx * dx + dy * dy <= 1.015 {
					raylib.ImageDrawPixel(&canvas.image, x, y, shape.color)
				}
			}
		}
	}
	
	for s in shapes {
		if s.outline.width > 0 {
			outline_shape := s
			outline_shape.size.x += i32(s.outline.width)
			outline_shape.size.y += i32(s.outline.width)
			outline_shape.color = s.outline.color
			
			write_pixels(canvas, outline_shape)
		}

		write_pixels(canvas, s)
	}
}

// TODO: Add curved edges.
draw_rectangles :: proc(canvas: ^Canvas, shapes: [dynamic]Shape_Rectangle) {
	for s in shapes {
		if s.outline.width > 0 {
			ow := i32(s.outline.width)
			half_ow := i32(ow / 2)
			quar_ow := i32(ow / 4)

			full_ol_x := s.size.x + half_ow
			full_ol_y := s.size.y + half_ow
			raylib.DrawRectangle(s.position.x - quar_ow, s.position.y - quar_ow, full_ol_x, full_ol_y, s.outline.color)
		}

		raylib.DrawRectangle(s.position.x, s.position.y, s.size.x, s.size.y, s.color)
	}
}

// TODO: Add curved edges.
draw_lines :: proc(canvas: ^Canvas, shapes: [dynamic]Shape_Line) {
	point_to_v2 :: proc(v: Vector) -> (raylib.Vector2) {
		return raylib.Vector2{f32(v.x), f32(v.y)}
	}

	write_pixels :: proc(canvas: ^Canvas, s: Shape_Line) {
		radius := s.width / 2
	
	
		start_position := raylib.Vector2{f32(s.point1.x), f32(s.point1.y)}
		end_position := raylib.Vector2{f32(s.point2.x), f32(s.point2.y)}

		line_vector := end_position - start_position
		line_length_squared := linalg.dot(line_vector, line_vector)

		min_x := int(math.floor(min(start_position.x, end_position.x) - f32(radius)))
		max_x := int(math.ceil(max(start_position.x, end_position.x) + f32(radius)))
		min_y := int(math.floor(min(start_position.y, end_position.y) - f32(radius)))
		max_y := int(math.ceil(max(start_position.y, end_position.y) + f32(radius)))

		radius_squared := f32(radius * radius)

		for y := min_y; y <= max_y; y += 1 {
			for x := min_x; x <= max_x; x += 1 {
				pixel_position := raylib.Vector2{
					f32(x) + 0.5,
					f32(y) + 0.5,
				}

				point_to_start := pixel_position - start_position

				t : f32 = 0.0
				if line_length_squared > 0 {
					t = linalg.dot(point_to_start, line_vector) / line_length_squared
					t = clamp(t, 0.0, 1.0)
				}

				closest_point := start_position + line_vector * t
				distance_squared := linalg.length2(pixel_position - closest_point)

				if distance_squared <= radius_squared {
					raylib.ImageDrawPixel(&canvas.image, i32(x), i32(y), s.color)
				}
			}
		}
	}

	for s in shapes {
		if s.outline.width > 0 {
			outline_shape := s
			outline_shape.width += s.outline.width * 2
			outline_shape.color = s.outline.color
			
			write_pixels(canvas, outline_shape)
		}

		write_pixels(canvas, s)
	}
}

create_canvas :: proc(width, height: int, clear_color: raylib.Color) -> Canvas {
	canvas : Canvas
	canvas.image = raylib.GenImageColor(i32(width), i32(height), clear_color)
	canvas.texture = raylib.LoadTextureFromImage(canvas.image)
	canvas.width = width
	canvas.height = height
	canvas.clear_color = clear_color

	return canvas
}

start_frame :: proc(canvas: ^Canvas) {
	raylib.ImageClearBackground(&canvas.image, canvas.clear_color)
}

present_frame :: proc(canvas: ^Canvas) {
	raylib.UpdateTexture(canvas.texture, canvas.image.data)

	raylib.DrawTextureEx(canvas.texture, canvas.screen_coords, 0.0, canvas.screen_scale, raylib.WHITE)
}
