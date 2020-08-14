// Goal: draw a single rotating triangle
package rotate_triangle 

import "core:fmt"
import "core:math"
import "core:time"
import "core:math/linalg"
import sdl "shared:odin-sdl2"

WIDTH :: 700;
HEIGHT:: 450;
DT_UPDATE :: 16_500_000; // nanoseconds 

Color :: distinct [3]u8; 
palette : [216]Color;

Float :: f32;
Vec3 :: [3]f32;
Tri ::  [3]Vec3;
Mesh :: [dynamic]Tri; 
Mat4x4 :: linalg.Matrix4x4;
Mat1x4 :: linalg.Matrix1x4;


rotation : Float = 0.0;

draw_triangle :: proc(rdr : ^sdl.Renderer, in_data : Tri)
{
	using linalg;
	data := in_data;
	proj_mat := matrix4_perspective(math.PI / 2, WIDTH/HEIGHT,0.1,100);
	rot_mat := matrix3_rotate(math.PI / 360.0 * rotation, Vector3{0.5,0.5,0.5}); 

	//data : [3]Vec3 = { {0, 0, 0}, {0, 1, 0}, {1, 1, 0} };
	// rotate
	data_rotated := [?][1][3]Float {
		matrix_mul_differ(rot_mat, Matrix1x3{ {data[0].x, data[0].y, data[0].z}  }),
		matrix_mul_differ(rot_mat, Matrix1x3{ {data[1].x, data[1].y, data[1].z}  }),
		matrix_mul_differ(rot_mat, Matrix1x3{ {data[2].x, data[2].y, data[2].z}  }),
	};
	// copy rotated data back to data
	fmt.println("data_rotated:\n", data_rotated, "type:", typeid_of(type_of(data_rotated)));
	data = {data_rotated[0][0], data_rotated[1][0], data_rotated[2][0]} ;
	fmt.println("data should == data_rotated:\n", data, "type:", typeid_of(type_of(data)));

	// translate into screen 
	for _, i in data do data[i].z += 3000.0;

	// project onto screen
	data_projected := [?][1][4]Float {
		matrix_mul_differ(proj_mat, Matrix1x4{ {data[0].x, data[0].y, data[0].z, 1.0}  }),
		matrix_mul_differ(proj_mat, Matrix1x4{ {data[1].x, data[1].y, data[1].z, 1.0}  }),
		matrix_mul_differ(proj_mat, Matrix1x4{ {data[2].x, data[2].y, data[2].z, 1.0}  }),
	};

	// copy projected data back to data
	fmt.println("data_projected:\n", data_projected, "type:", typeid_of(type_of(data_projected)));
	data = {
		{data_projected[0][0][0], data_projected[0][0][1], data_projected[0][0][2]},
		{data_projected[1][0][0], data_projected[1][0][1], data_projected[1][0][2]},
		{data_projected[2][0][0], data_projected[2][0][1], data_projected[2][0][2]}
	};
	fmt.println("data should == data_projected\n", data, "type:", typeid_of(type_of(data)));

	// translate & scale
	for _, i in data {
		data[i].x += 0.4;
		data[i].y += 0.4;
		data[i].x *= 0.5 * Float(WIDTH);
		data[i].y *= 0.5 * Float(HEIGHT);
	}
	// draw
	{
		sdl.set_render_draw_color(rdr, expand_to_tuple(palette[19]), 255);
		sdl.render_draw_line(rdr, i32(data[0].x), i32(data[0].y), i32(data[1].x), i32(data[1].y));
		sdl.set_render_draw_color(rdr, expand_to_tuple(palette[8]), 255);
		sdl.render_draw_line(rdr, i32(data[1].x), i32(data[1].y), i32(data[2].x), i32(data[2].y));
		sdl.set_render_draw_color(rdr, expand_to_tuple(palette[22]), 255);
		sdl.render_draw_line(rdr, i32(data[2].x), i32(data[2].y), i32(data[0].x), i32(data[0].y));
	}
}


main :: proc() {
	/* initialize start */
	t_info := Timing_Info{fps_min = 10_000};
	when true do init_palette();
	win, rdr := init_sdl();
	defer sdl.quit();
	running := true;
	cube_data := [?]Tri{
		{ {0, 0, 0}, {0, 1, 0}, {1, 1, 0} },  // South
		{ {0, 0, 0}, {1, 1, 0}, {1, 0, 0} },

		{ {1, 0, 0}, {1, 1, 0}, {1, 1, 1} }, // East
		{ {1, 0, 0}, {1, 1, 1}, {1, 0, 1} },

		{ {1, 0, 1}, {1, 1, 1}, {0, 1, 1} }, // North
		{ {1, 0, 1}, {0, 1, 1}, {0, 0, 1} },

		{ {0, 0, 1}, {0, 1, 1}, {0, 1, 0} }, // West
		{ {0, 0, 1}, {0, 1, 0}, {0, 0, 0} },

		{ {0, 1, 0}, {0, 1, 1}, {1, 1, 1} }, // Top
		{ {0, 1, 0}, {1, 1, 1}, {1, 1, 0} },

		{ {1, 0, 1}, {0, 0, 1}, {0, 0, 0} }, // Bottom
		{ {1, 0, 1}, {0, 0, 0}, {1, 0, 0} },
	};
	/* initialize end */

	/* main loop */
	for running {
		e: sdl.Event;
		for sdl.poll_event(&e) != 0 {
			if e.type == sdl.Event_Type.Key_Down {
				if e.key.keysym.scancode == sdl.Scancode.Escape do running = false;
				//if e.key.keysym.scancode == sdl.Scancode.Space do place_droplet();
			}
			if e.type == sdl.Event_Type.Quit do	running = false;
		}
		if t_info.update_accum >= DT_UPDATE {
			t_info.update_accum -= DT_UPDATE;
			sdl.set_render_draw_color(rdr, expand_to_tuple(palette[14]), 255);
			sdl.render_clear(rdr);
			/* draw */
			sdl.set_render_draw_color(rdr, expand_to_tuple(palette[60]), 255);
			data : [3]Vec3 = { {0, 0, 0}, {0, 1, 0}, {1, 1, 0} };
			for _, i in cube_data do draw_triangle(rdr, cube_data[i]);
			/* update */
			rotation += 0.2;
		}
		sdl.render_present(rdr);
		t_info = update_counters_and_show_fps(win, t_info);	
		/* cap the frame rate */
		time.sleep(2 * time.Millisecond);
	}
	fmt.println("Running time (seconds) ", t_info.total_running_time / time.Second);
}

Timing_Info :: struct {
	fstart : time.Time,
	update_accum : time.Duration, fps_accum : time.Duration, frame_count: i64,
	fps_max : i64, fps_min : i64,
	total_running_time : time.Duration ,
}


update_counters_and_show_fps :: proc(win : ^sdl.Window, t : Timing_Info) -> Timing_Info {
	using time;
	t_out := t;
	{ 
		_dt_frame := diff(t.fstart, time.now());
		t_out.update_accum += _dt_frame;
		t_out.fps_accum += _dt_frame;
	}
	t_out.fstart = now();
	t_out.frame_count += 1;
	// report fps in title bar 
	if t.fps_accum >= 1_000_000_000 {
		{
			if t_out.total_running_time > 2 * Second {
				// only record min and max after running for a few secs
				if t_out.fps_max < t.frame_count do t_out.fps_max = t.frame_count;
				if t_out.fps_min > t.frame_count do t_out.fps_min = t.frame_count;
			}
			t_out.total_running_time += 1 * Second;
			_fps_str := fmt.aprintf("fps %d max %d min %d", t.frame_count, t.fps_max, t.fps_min);
			sdl.set_window_title(win,cstring(raw_data(_fps_str)));
		}
		t_out.frame_count = 0;
		t_out.fps_accum = 0;
	}
	return t_out;
}


init_palette :: proc() {
	cidx: u8;
	for ridx := 0; ridx <= 255; ridx += 51 do
	for gidx := 0; gidx <= 255; gidx += 51 do
	for bidx := 0; bidx <= 255; bidx += 51 {
		palette[cidx] = Color{cast(u8)ridx, cast(u8)gidx, cast(u8)bidx};
		cidx += 1;
	}
}

init_sdl :: proc() -> (win : ^sdl.Window, rdr : ^sdl.Renderer) {
	sdl.init(sdl.Init_Flags.Everything);
	win = sdl.create_window("", i32(sdl.Window_Pos.Undefined), 
	i32(sdl.Window_Pos.Undefined), i32(WIDTH), i32(HEIGHT), sdl.Window_Flags(0));
	rdr = sdl.create_renderer(win, -1, sdl.Renderer_Flags.Accelerated);
	return win, rdr;
}



