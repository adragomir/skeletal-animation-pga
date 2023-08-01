MAX_WEIGHTS :: 4;
MAX_JOINTS :: 1000;

#load "pga.jai";
#load "parse_utils.jai";
#load "render.jai";
#load "mesh_anim.jai";

state: struct {
    window: Window_Type;
    current_window_width, current_window_height: s32;
    running: bool;
    control_camera: bool;

    font: *simp.Dynamic_Font;
    checkbox_font: *simp.Dynamic_Font;
    slider_font: *simp.Dynamic_Font;
    dropdown_font: *simp.Dynamic_Font;

    loaded_meshes: Table(string, Skinned_Mesh);
    loaded_animations: Table(string, Sampled_Animation);
    mesh: *Skinned_Mesh;
    pose: Skeleton_Pose;
}

params: struct {
	mesh_names: []string;
	mesh_index: s32;
	animation_names: []string;
	animation_index: s32;
	skeleton_color := Vector3.{ 1, 1, 1 };
	show_skeleton := true;
	show_mesh := false;
	show_animation := false;
	use_pga_animation := true;
	animation_time := 0.0;	// In samples
	animation_speed_in_fps := 0.0;
	interpolation_mode := Interpolation_Mode.LINEAR;
};

update_ui :: (delta_time: float) {
	using params;

	glDisable(GL_DEPTH_TEST);
	glDepthMask(GL_FALSE);

	simp.set_shader_for_color();
	current_time := to_float64_seconds(current_time_monotonic());
	w, h := simp.get_render_dimensions(state.window);
	getrect.ui_per_frame_update(state.window, w, h, current_time);

	// Init themes
	label_theme: getrect.Label_Theme;
	label_theme.font = state.font;
	checkbox_theme: getrect.Checkbox_Theme;
	checkbox_theme.font = state.checkbox_font;
	slider_theme: getrect.Slider_Theme;
	slider_theme.foreground.font = state.slider_font;
	dropdown_theme := getrect.default_overall_theme.dropdown_theme;
	dropdown_theme.theme_for_current_value.font = state.dropdown_font;
	dropdown_theme.theme_for_each_choice.font = state.dropdown_font;
	dropdown_theme.theme_for_current_choice.font = state.dropdown_font;

	k := state.current_window_height / 45.0;
	pad := cast(float) state.font.character_height * 1.6;
	dropdown_offset := w * 0.2;
	dropdown_width  := w * 0.1;
	r := getrect.get_rect(
		k, h - k * 2,
		k, xx state.font.character_height
	);
	// Mesh selection
	{
		r.w = xx simp.prepare_text(state.font, "Mesh: ");
		getrect.label(r, "Mesh: ", *label_theme);
		r.x += dropdown_offset;
		defer r.x -= dropdown_offset;
		r.w = dropdown_width;
		getrect.dropdown(
			r,
			mesh_names,
			*mesh_index,
			*dropdown_theme
		);
	}
	r.y -= pad;
	// Animation selection
	{
		r.w = xx simp.prepare_text(state.font, "Animation: ");
		getrect.label(r, "Animation: ", *label_theme);
		r.x += dropdown_offset;
		defer r.x -= dropdown_offset;
		r.w = dropdown_width;
		getrect.dropdown(
			r,
			animation_names,
			*animation_index,
			*dropdown_theme
		);
	}
	r.y -= pad;
	// Show Skeleton checkbox
	{
		r.w = r.h + xx simp.prepare_text(state.checkbox_font, "Show Skeleton");
		pressed := getrect.base_checkbox(r, "Show Skeleton", show_skeleton, *checkbox_theme);
		show_skeleton ^= pressed;
	}
	r.y -= pad;
	// Show Mesh checkbox
	{
		r.w = r.h + xx simp.prepare_text(state.checkbox_font, "Show Mesh");
		pressed := getrect.base_checkbox(r, "Show Mesh", show_mesh, *checkbox_theme);
		show_mesh ^= pressed;
	}
	r.y -= pad;
	// Show Animations checkbox
	{
		r.w = r.h + xx simp.prepare_text(state.checkbox_font, "Show Animations");
		pressed := getrect.base_checkbox(r, "Show Animations", show_animation, *checkbox_theme);
		show_animation ^= pressed;
	}
	r.y -= pad;
	{
		r.w = r.h + xx simp.prepare_text(state.checkbox_font, "Use PGA Animation");
		pressed := getrect.base_checkbox(r, "Use PGA Animation", use_pga_animation, *checkbox_theme);
		use_pga_animation ^= pressed;
	}
	r.y -= pad;
	// Animation speed slider
	{
		r.w = w * 0.1 + xx simp.prepare_text(state.slider_font, "Animation Speed: 120.00 FPS");
		getrect.slider(r, *animation_speed_in_fps, 0.0, 120.0, 1.0, *slider_theme, "Animation Speed: ", "FPS");
	}
	r.y -= pad;
	// Animation time slider
	{
		sample_count := 0;
		if animation_index > 0 {
			anim := table_find_pointer(*state.loaded_animations, animation_names[animation_index]);
			sample_count = anim.sample_count;
		}
		text := tprint("Animation Time: %.00", sample_count);
		r.w = w * 0.1 + xx simp.prepare_text(state.slider_font, text);
		getrect.slider(r, *animation_time, 0.0, xx sample_count, 1.0, *slider_theme, "Animation Time: ", "");
	}
	r.y -= pad;
	// Interpolation mode
	{
		r.w = xx simp.prepare_text(state.font, "Interpolation Mode: ");
		getrect.label(r, "Interpolation Mode: ", *label_theme);
		r.x += dropdown_offset;
		defer r.x -= dropdown_offset;
		r.w = dropdown_width;
		getrect.dropdown(
			r,
			string.[ "Nearest", "Linear", "Linear, slerp" ],
			cast(*s32) *interpolation_mode,
			*dropdown_theme
		);
	}

	r = getrect.get_rect(k, pad, k, k);
	{
		TEXT :: "Use ESC to toggle camera controls, WSADEQ to move, SHIFT to speed up, ALT+F4 to quit";
		r.w = k + xx simp.prepare_text(state.font, TEXT);
		getrect.label(r, TEXT, *label_theme);
	}

	getrect.draw_popups();
}

reinit_fonts :: init_fonts;
init_fonts :: () {
	// I want a pixel size of 20 with a window height of 720 => 720 / 36 = 20
	pixel_height := state.current_window_height / 36;
	state.font = simp.get_font_at_size("data/fonts", "OpenSans-Regular.ttf", pixel_height);
	assert(state.font != null);
	pixel_height = state.current_window_height / 40;
	state.checkbox_font = simp.get_font_at_size("data/fonts", "OpenSans-Regular.ttf", pixel_height);
	assert(state.checkbox_font != null);
	pixel_height = state.current_window_height / 45;
	state.slider_font = simp.get_font_at_size("data/fonts", "OpenSans-Italic.ttf", pixel_height);
	assert(state.slider_font != null);
	state.dropdown_font = state.slider_font;
}

make_matrix :: (pos: Vector3, rot: Quaternion, scale: Vector3) -> Matrix4 {
	return make_translation_matrix4(pos) * 
	make_scale_matrix4(scale) *
    rotation_matrix(Matrix4, rot);
}

main :: () {
	executable_path := path_strip_filename(get_path_of_running_executable());
	set_working_directory(executable_path);

    state.current_window_width = 1960;
    state.current_window_height = 1280;
	state.window = create_window(state.current_window_width, state.current_window_height, "Skeletal Animation");
	simp.set_render_target(state.window);

	getrect.ui_init();
	init_fonts();
	if !init_rendering_objects()  return;
	{
	    {
	        mesh: Skinned_Mesh;
	        loaded := load_mesh_from_file(*mesh, "data/Mannequin.mesh");
		    init_mesh_rendering_objects(*mesh);
		    table_add(*state.loaded_meshes, "Mannequin", mesh);

		    anim: Sampled_Animation;
		    loaded = load_animation_from_file(*anim, "data/Run_Forward.anim");
		    table_add(*state.loaded_animations, "Run_Forward", anim);

		    loaded = load_animation_from_file(*anim, "data/Standing_Idle.anim");
		    table_add(*state.loaded_animations, "Standing_Idle", anim);
	    }

		{
		    mesh: Skinned_Mesh;
		    loaded := load_pga_mesh_from_file(*mesh, "data/jimmy_anim_format.json");
		    init_mesh_rendering_objects(*mesh);
		    table_add(*state.loaded_meshes, "Jimmy", mesh);
		    anims := load_pga_anims_from_file(*mesh, "data/jimmy_anim_format.json");

		    table_add(*state.loaded_animations, "Jimmy_Jump", anims[0]);
		    table_add(*state.loaded_animations, "Jimmy_Run", anims[1]);
		    table_add(*state.loaded_animations, "Jimmy_Stride", anims[2]);
		    table_add(*state.loaded_animations, "Jimmy_Idle", anims[3]);
		    table_add(*state.loaded_animations, "Jimmy_Zombie", anims[4]);
        }


	    params.mesh_names = NewArray(state.loaded_meshes.count + 1, string);
	    params.mesh_names[0] = "None";
	    i := 1;
	    for val, name: state.loaded_meshes {
		    params.mesh_names[i] = name;
		    i += 1;
	    }
	    params.animation_names = NewArray(state.loaded_animations.count + 1, string);
	    params.animation_names[0] = "None";
	    i = 1;
	    for val, name: state.loaded_animations {
		    params.animation_names[i] = name;
		    i += 1;
	    }
	    // Start the program with a mesh and some animation
	    params.mesh_index = xx(params.mesh_names.count - 2);
	    params.animation_index = xx(params.animation_names.count - 1);
    }

	// Position the camera in a nice way
	render_state.camera.position = xyz(1, 1.3, 2.3);
	render_state.camera.euler_angles.x = -20 * PI / 180.0;
	render_state.camera.euler_angles.y = 10 * PI / 180.0;
	state.running = true;
	delta_time := 0.01667;
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	while state.running {
		frame_start := current_time_monotonic();
		reset_temporary_storage();
		update_window_events();
		for get_window_resizes() {
			if it.window == state.window
			&& ((state.current_window_width != it.width) || (state.current_window_height != it.height)) {
				state.current_window_width = it.width;
				state.current_window_height = it.height;
				reinit_fonts();	// We want the fonts to scale with the window
			}
		}
		for events_this_frame {
	        getrect.getrect_handle_event(it);
	        if it.type == {
	        case .QUIT;
		        state.running = false;
	        case .KEYBOARD;
		        if it.key_pressed {
			        if it.key_code == .ESCAPE
				        set_camera_control(!state.control_camera);
			        if it.key_code == .F4 && it.alt_pressed
				        state.running = false;
		        }
	        }
		}

		update_frame(delta_time);

		glDepthMask(GL_TRUE);
		glEnable(GL_DEPTH_TEST);
		simp.update_window(state.window);
		simp.clear_render_target(0.1, 0.1, 0.1, 1);
		glClear(GL_DEPTH_BUFFER_BIT);
		if state.mesh && params.show_mesh {
			if params.use_pga_animation {
			    draw_mesh(state.mesh, Matrix4_Identity, state.pose.skinning_matrices_pga);
			} else {
			    draw_mesh(state.mesh, Matrix4_Identity, state.pose.skinning_matrices);
			}
		}
		// Draw coordinate axes
		draw_line(.{}, .{x=1}, .{x=1, w=1});
		draw_line(.{}, .{y=1}, .{y=1, w=1});
		draw_line(.{}, .{z=1}, .{z=1, w=1});
		// Draw grid
		for i: -10..10
			draw_line(xyz(xx i, 0, -10), xyz(xx i, 0, 10), .{0.4, 0.4, 0.4, 1});
		for i: -10..10
			draw_line(xyz(-10, 0, xx i), xyz(10, 0, xx i), .{0.4, 0.4, 0.4, 1});

		if state.mesh && params.show_skeleton {
			// Disable depth mask and testing so we can see the skeleton through other things
			glDepthMask(GL_FALSE);
			glDisable(GL_DEPTH_TEST);
			draw_pose(state.pose, Matrix4_Identity, xyzw(params.skeleton_color, 1));
		}

		update_ui(delta_time);

		simp.swap_buffers(state.window);
		sleep_milliseconds(10);
		frame_end := current_time_monotonic();
		delta_time = cast(float) to_float64_seconds(frame_end - frame_start);
	}
}

set_camera_control :: inline(control: bool) {
	state.control_camera = control;
}

get_current_mesh :: () -> *Skinned_Mesh {
	new_mesh: *Skinned_Mesh;
	if params.mesh_index == 0
		new_mesh = null;
	else
		new_mesh = table_find_pointer(*state.loaded_meshes, params.mesh_names[params.mesh_index]);
	return new_mesh;
}

get_current_animation :: () -> *Sampled_Animation {
	anim: *Sampled_Animation;
	if params.animation_index > 0
		anim = table_find_pointer(*state.loaded_animations, params.animation_names[params.animation_index]);
	else
		anim = null;
	return anim;
}

update_frame :: (delta_time: float) {
	// Lock the cursor in the middle of the screen when controlling the camera
	if state.control_camera {
		x, y, w, h := get_dimensions(state.window, false);
	}

	update_flying_camera(*render_state.camera, delta_time);

	// Update the mesh if the user selected another one.
	// Ideally we would only call table_find_pointer when we know
	// the user selected another mesh, but I can't find a way to
	// do that in GetRect.
	new_mesh := get_current_mesh();

	if state.mesh != new_mesh {
		state.mesh = new_mesh;
		// We changed the mesh, so reallocate a new pose
		free_pose(*state.pose);
		if state.mesh {
			state.pose = make_pose_for_skeleton(state.mesh);
		    reset_to_bind_pose(*state.pose);
		}
	}

	anim := get_current_animation();;

	if state.mesh {
		// We reset to the bind pose because the animation
		// might not have all of the joints our pose has.
		// reset_to_bind_pose(*state.pose);
		if anim && params.show_animation {
			sample_animation(anim, params.animation_time, *state.pose, params.interpolation_mode);
		}
	}

	// Increment animation time
	if anim {
		params.animation_time += delta_time * params.animation_speed_in_fps;
		params.animation_time = fmod_cycling(params.animation_time, xx anim.sample_count);
	} else
		params.animation_time = 0;

	// We transpose the result because OpenGL stores matrices in column-major
	if state.mesh
		generate_skinning_matrices(*state.pose, transpose_result = true);
}

is_key_down :: inline(key: Key_Code) -> bool #must {
	return(input_button_states[cast(s64) key] & .DOWN) != 0;
}

// This is incomplete, and won't work for matrices that have shear.
// In that case we would use a polar decomposition, so this assumes
// your matrix does not have shear.
decompose_transform :: inline(mat: Matrix4) -> translation: Vector3, rotation: Quaternion, scale: Vector3 {
	translation := xyz(
		mat._14,
		mat._24,
		mat._34
	);
	rotation := get_rotation(mat);
	scale := xyz(
		length(xyz(mat._11, mat._21, mat._31)),
		length(xyz(mat._12, mat._22, mat._32)),
		length(xyz(mat._13, mat._23, mat._33))
	);
	return translation, rotation, scale;
}

#import "Basic";
#import "String";
#import "Window_Creation";
#import "Input";
#import "Math";
#import "File";
#import "File_Utilities";
#import "System";
#import "GL";
#import "Hash_Table";
simp :: #import "Simp";
getrect :: #import "GetRect";
#import "Jason";
