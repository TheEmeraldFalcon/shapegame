package pxcv

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

Vector :: struct {
	x : i32,
	y : i32,
}

Canvas :: struct {
	width : int,
	height : int,

	clear_color: raylib.Color,

	image : raylib.Image,
	texture : raylib.Texture
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

draw_ellipses :: proc(canvas: ^Canvas, shapes : [dynamic]Shape_Ellipse) {
	write_pixels :: proc(canvas: ^Canvas, shape: Shape_Ellipse) {
		center_x := shape.position.x
		center_y := shape.position.y
		radius_h := shape.size.x
		radius_v := shape.size.y

		for y in center_y - radius_v..=center_y + radius_v {
			for x in center_x - radius_h..=center_x + radius_h {
				(x >= 0 && x < canvas.image.width && y >= 0 && y < canvas.image.height) or_continue

				dx := (x - center_x) / radius_h
				dy := (y - center_y) / radius_v
				if dx * dx + dy * dy <= 1.0 {
					raylib.ImageDrawPixel(&canvas.image, x, y, shape.color)
				}
			}
		}
	}
	
	for s in shapes {
//		if s.outline.width > 0 {
//			full_ol_x := f32(s.size.x) + (f32(s.outline.width) / 2.0)
//			full_ol_y := f32(s.size.y) + (f32(s.outline.width) / 2.0)
////			raylib.DrawEllipse(s.position.x, s.position.y, full_ol_x, full_ol_y, s.outline.color)
//		}

		write_pixels(canvas, s)
		//raylib.DrawEllipse(s.position.x, s.position.y, f32(s.size.x), f32(s.size.y), s.color)
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
	
	for s in shapes {
		p1 := point_to_v2(s.point1)
		p2 := point_to_v2(s.point2)

		if s.outline.width > 0 {
			ow := f32(s.outline.width / 2.0)
			
			raylib.DrawLineEx(p1, p2, f32(s.width) + ow, s.outline.color)
		}

		raylib.DrawLineEx(p1, p2, f32(s.width), s.color)
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

	raylib.DrawTextureEx(canvas.texture, {0., 0.}, 0., 8.0, raylib.WHITE)
}
