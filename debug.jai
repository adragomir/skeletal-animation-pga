print_mat :: (in: Matrix4) -> string {
    sb: String_Builder;
    for row: 0..3 {
        print_to_builder(*sb, "row%: [% % % %]\n", row, 
            formatFloat(in.coef[row][0], width=10), 
            formatFloat(in.coef[row][1], width=10), 
            formatFloat(in.coef[row][2], width=10), 
            formatFloat(in.coef[row][3], width=10), 
        );
    }
    return builder_to_string(*sb);
}

approx_eq :: (a: $T/interface AnyMatrix, b: T) -> bool {
    for i: 0..a.floats.count-1 {
        if isnan(a.floats[i]) || isnan(b.floats[i]) return false;
        if (a.floats[i] - b.floats[i]) > 0.0001 return false;
    }
    return true;
}

// dump_joint :: (j: *Skeleton_Pose.Joint) {
//     print(">> pose joint: \n");
//     print("  local_position = %\n", j.local_position);
//     print("  local_orientation = %\n", j.local_orientation);
//     print("  local_scale = %\n", j.local_scale);
//     print("  keyframe_pos = %\n", j.keyframe_pos);
//     print("  keyframe_rot = %\n", j.keyframe_rot);
//     print("<<\n");
// }
// dump_joint :: (j: *Joint_Sample) {
//     print(">> sample: \n");
//     print("local_position = %\n", j.local_position);
//     print("local_orientation = %\n", j.local_orientation);
//     print("local_scale = %\n", j.local_scale);
//     print("keyframe_pos = %\n", stringify(j.keyframe_pos));
//     print("keyframe_rot = %\n", stringify(j.keyframe_rot));
//     print("<<\n");
// }

// debug_mesh_anim :: (mesh: *Skinned_Mesh, anim: *Sampled_Animation) {
//     // prepare to load the animation
//     print("Checking skeleton joint\n");
//     for j: mesh.joints {
//         old := j.local_bind_transform;
//         new := matrix4x4(j.local_origin_pos * j.local_origin_rot);
//         if !approx_eq(old, new) {
//             print("BAD JOINT %\n", it_index);
//             exit(1);
//         }
//     }
//     print("Checking ANIM\n");
//     for joint: anim.joints {
//         name := joint.name;
//         for sample_index: 0..anim.sample_count - 1 {
//             sample := joint.samples[sample_index];
//             old := make_matrix(
//                 sample.local_position, 
//                 sample.local_orientation, 
//                 sample.local_scale, 
//             );
//             new := matrix4x4(sample.keyframe_pos * sample.keyframe_rot);
//             if !approx_eq(old, new) {
//                 print("BAD SAMPLE joint=% sample=%\n", name, sample_index);
//                 exit(1);
//             }
//         }
//     }
//     for j: mesh.joints {
//         old := j.local_bind_transform;
//         new := matrix4x4(j.local_origin_pos * j.local_origin_rot);
//         if !approx_eq(old, new) {
//             print("BAD JOINT %\n", it_index);
//             exit(1);
//         }
//     }
//     pose := make_pose_for_skeleton(mesh);
//     reset_to_bind_pose(*pose);
//     print("Checking pose joints\n");
//     for j: pose.joints {
//         old := make_matrix(j.local_position, j.local_orientation, j.local_scale);
//         new := matrix4x4(j.keyframe_pos * j.keyframe_rot);
//         if !approx_eq(old, new) {
//             print("BAD JOINT %\n", it_index);
//             exit(1);
//         }
//     }
//     print("SAMPLING ---------\n");
//     for frame: 0..(anim.sample_count - 1) {
//         print("  Checking frame: %\n", frame);
//         sample_animation(anim, frame + 0.5, *pose);
//         print("    checking pose joints\n");
//         for j: pose.joints {
//             old := make_matrix(j.local_position, j.local_orientation, j.local_scale);
//             new := matrix4x4(j.keyframe_pos * j.keyframe_rot);
//             if !approx_eq(old, new) {
//                 print("  BAD JOINT %:\n%\n%\n", it_index, old, new);
//                 exit(1);
//             }
//         }
//         // skinning
//         print("    checking skin matrices\n");
//         generate_skinning_matrices(*pose, true);
//         for i: 0.. pose.skinning_matrices.count - 1 {
//             print("mat1: %\n", print_mat(pose.skinning_matrices[i]));
//             print("mat2: %\n", print_mat(pose.skinning_matrices_pga[i]));
//             if !approx_eq(pose.skinning_matrices[i], pose.skinning_matrices_pga[i]) {
//                 print("  BAD skin matrix %\n", i);
//                 exit(1);
//             }
//         }
//
//     }
// }

main_debug :: () {
	if false {
	    pga_tests();
	    exit(1);
	}

	if false {
	    a  : Rotor;
	    a.p1 = vec128(float.[0.700798, -0.211767, -0.652081, 0.197046]);
	    print("%\n", stringify(a));
	    b: Rotor;
	    b.p1 = vec128(float.[0.700798, -0.211767, -0.652081, 0.197046]);
	    nota := ~a;
	    print("nota: %\n", stringify(nota));
	    tmp1 := b * nota;
	    print("tmp1: %\n", stringify(tmp1));
	    print("%\n", stringify(b));
	    out := slerp(a, b, 0.3);
	    print("%\n", stringify(out));

        exit(1);
	}
	#if false {
	    // original bone
	    make_matrix :: (pos: Vector3, rot: Vector3) -> Matrix4 {
	        return make_translation_matrix4(pos) * 
	        make_scale_matrix4(Vector3.{1, 1, 1}) *
            rotation_matrix(Matrix4, hpb_to_quaternion(rot));
	    }
	    make_motor :: (pos: Vector3, rot: Vector3) -> Motor {
            return Translator.make(pos) *
                Rotor.make(Euler_Angles.{rot.x, rot.y, rot.z});
	    }
	    dump :: (in: Matrix4) {
            print("matrix usual: %\n", print_mat(in));
	        {
	            trans, rot, scale := decompose_transform(in);
	            print("  DECOMPOSE\n");
	            print("  trans: %\n", trans);
	            print("  rot: %\n", rot);
	            print("  scale: %\n", scale);
	        }
	    }

	    // build matrix the usual way
	    matrix_usual := make_matrix(Vector3.{2.0, 2.0, 2.0}, Vector3.{0.2, 0.2, 0.2});
	    dump(matrix_usual);
	    matrix_usual_twice := matrix_usual * matrix_usual;
	    dump(matrix_usual_twice);
	    motor := make_motor(Vector3.{2.0, 2.0, 2.0}, Vector3.{0.2, 0.2, 0.2});
	    motor_twice := motor * motor;
	    matrix_pga := matrix4x4(motor);
	    dump(matrix_pga);
	    matrix_pga_twice := matrix4x4(motor * motor);
	    dump(matrix_pga_twice);

		mesh: Skinned_Mesh;
		loaded := load_pga_mesh_from_file(*mesh, "data/jimmy_anim_format.json");
		anims := load_pga_anims_from_file(*mesh, "data/jimmy_anim_format.json");

		anim_jump := anims[0];
		anim_run := anims[1];
		anim_stride := anims[2];
		anim_idle := anims[3];
		anim_zombie := anims[4];

		debug_mesh_anim(*mesh, *anim_jump);
		debug_mesh_anim(*mesh, *anim_run);
		debug_mesh_anim(*mesh, *anim_stride);
		debug_mesh_anim(*mesh, *anim_idle);
		debug_mesh_anim(*mesh, *anim_zombie);

	    exit(1);
	}

}
