Vertex :: struct {
    position: Vector3;
    normal  : Vector3;
    // We can have at most 4 weights, but they have to sum up
    // to 1, so the last one can be calculated and we don't store it.
    weights : Vector3;
    joints  : [4]s16;
}

Skinned_Mesh :: struct {
    #as using skeleton: Skeleton;
    vertices: []Vertex;
    indices : []u32;
    vao, vbo, ibo: GLuint;
}

// The skeleton is separate from the mesh so that you
// can operate on a skeleton without refering to a mesh.
Skeleton :: struct {
    Joint :: struct {
        id: s16;
        // This is the matrix of the joint in the rest position,
        // relative to the parent's coordinate system
        local_bind_transform: Matrix4;
        // This is the inverse of the matrix of the joint in model space.
        // Why we have this matrix is explained in anim.jai:generate_skinning_matrices
        inverse_bind_transform: Matrix4;

        // PGA
        local_origin_pos: Translator;
        local_origin_rot: Rotor;
        bind_pose: Motor;
        bind_pose_inverse: Motor;

        parent: *Joint;
    }

    name_to_joint_id: Table(string, s16);
    joint_id_to_name: Table(s16, string);
    joints: [] Joint;    // Root joint is joints[0]
}

Joint_Sample :: struct {
    local_position: Vector3;
    local_orientation: Quaternion;
    local_scale: Vector3;

    keyframe_motor: Motor;
    total_keyframe_motor: Motor;
}

Joint_Animation :: struct {
    name: string;
    samples: []Joint_Sample;
}

Sampled_Animation :: struct {
    sample_count: s64;
    joints: []Joint_Animation;
}

Skeleton_Pose :: struct {
    Joint :: struct {
        parent: *Joint;
        #as using sample: Joint_Sample;
        model_space_transform := Matrix4_Identity;
        model_space_motor: Motor;
    }

    skeleton: *Skeleton;
    joints: []Joint;
    skinning_matrices: []Matrix4;
    skinning_matrices_pga: []Matrix4;
}

load_mesh_from_file :: (mesh: *Skinned_Mesh, filename: string) -> bool {
    parse_joint :: (handler: *Text_File_Handler, mesh: *Skinned_Mesh, joint: *Skeleton.Joint) -> bool {
        name, ok := consume_next_line(handler);
        if !ok
            return false;
        joint.id = cast(s16) (joint - mesh.joints.data);

        table_add(*mesh.name_to_joint_id, copy_string(name), joint.id);
        table_add(*mesh.joint_id_to_name, joint.id, copy_string(name));
        joint.local_bind_transform, ok = parse_matrix4(handler);
        // Parse parent id
        parent_id: s16;
        parent_id, ok = parse_int(handler, s16);
        if !ok
            return false;
        // Set the inverse bind transform to the model space transform first.
        // We will invert the matrices after all the joints have been parsed.
        if parent_id >= 0 {
            if parent_id >= mesh.joints.count
                  return error_out(handler, "Invalid parent joint id.");
            parent := *mesh.joints[parent_id];
            joint.parent = parent;
            joint.inverse_bind_transform = parent.inverse_bind_transform * joint.local_bind_transform;
        } else {
            joint.parent = null;
            joint.inverse_bind_transform = joint.local_bind_transform;
        }

        return true;
    }

    parse_vertex :: (handler: *Text_File_Handler, mesh: *Skinned_Mesh, vertex: *Vertex) -> bool {
        ok: bool;
        vertex.position, ok = parse_vector3(handler);
        if !ok
            return false;
        vertex.normal, ok = parse_vector3(handler);
        if !ok
            return false;
        vertex.weights, ok = parse_vector3(handler);
        if !ok
            return false;
        vertex.joints, ok = parse_int_tuple(handler, 4, s16);
        if !ok
            return false;
        return true;
    }

    parse_triangle :: (handler: *Text_File_Handler, mesh: *Skinned_Mesh, index: s64) -> bool {
        tri, ok := parse_int_tuple(handler, 3, u32);
        if !ok
            return false;
        mesh.indices[index + 0] = tri[0];
        mesh.indices[index + 1] = tri[1];
        mesh.indices[index + 2] = tri[2];
        return true;
    }

    handler: Text_File_Handler;
    defer deinit(*handler);

    found_slash, dir, basename := split_from_right(filename, #char "/");
    if !found_slash then basename = filename;
    start_file(*handler, basename, filename, optional = false);
    if handler.failed
        return false;

    if handler.version != 1
        return error_out(handler, "Invalid version number.");

    ok: bool;
    mesh.joints.count, ok = parse_ident_and_int_line(*handler, "joint_count");
    if !ok
        return false;
    if mesh.joints.count > MAX_JOINTS
        return error_out(handler, "Too many joints(expected at most %, got %).", MAX_JOINTS, mesh.joints.count);

    mesh.vertices.count, ok = parse_ident_and_int_line(*handler, "vertex_count");
    if !ok
        return false;

    triangle_count: s64;
    triangle_count, ok = parse_ident_and_int_line(*handler, "triangle_count");
    if !ok
        return false;
    mesh.indices.count = triangle_count * 3;

    // Allocate all the data in one batch, so everything is contiguous
    all_data := alloc(size_of(Skeleton.Joint) * mesh.joints.count
        + size_of(Vertex) * mesh.vertices.count
        + size_of(u32) * mesh.indices.count
    );

    init(*mesh.name_to_joint_id, mesh.joints.count);
    mesh.joints.data   = all_data;
    mesh.vertices.data = cast(*Vertex) (mesh.joints.data + mesh.joints.count);
    mesh.indices.data  = cast(*u32) (mesh.vertices.data + mesh.vertices.count);
    
    // Parse joints
    line, found := consume_next_line(*handler);
    if line != "joints:"
        return error_out(handler, "Expected 'joints:', got '%' instead.", line);
    for * mesh.joints {
        if !parse_joint(*handler, mesh, it)
            return error_out(handler, "Could not parse joint %.", it_index);
    }
    // Inverse all the bind transforms we calculated while parsing the joints
    for * mesh.joints
        it.inverse_bind_transform = inverse(it.inverse_bind_transform);

    // Parse vertices
    line, found = consume_next_line(*handler);
    if line != "vertices:"
        return error_out(handler, "Expected 'vertices:', got '%' instead.", line);
    for * mesh.vertices
        if !parse_vertex(*handler, mesh, it)
            return error_out(handler, "Could not parse vertex %.", it_index);

    // Parse triangles
    line, found = consume_next_line(*handler);
    if line != "triangles:"
        return error_out(handler, "Expected 'triangles:', got '%' instead.", line);
    for i: 0..triangle_count - 1
        if !parse_triangle(*handler, mesh, i * 3)
            return error_out(handler, "Could not parse triangle %.", i);

    line, found = consume_next_line(*handler);
    if found
        return error_out(handler, "Expected EOF.");

    return true;
}

load_animation_from_file :: (anim: *Sampled_Animation, filename: string) -> bool {
    parse_joint :: (
        handler: *Text_File_Handler,
        anim: *Sampled_Animation,
        joint: *Joint_Animation,
        data: *void
    ) -> bool {
        line, ok := consume_next_line(handler);
        if !ok
            return error_out(handler, "Could not parse joint name.");
        // We don't make sure the name does not exist already
        // first, but let's keep this simple.
        joint.name = copy_string(line);
        joint.samples.data = data;
        joint.samples.count = anim.sample_count;
        for i: 0..anim.sample_count - 1 {
            sample := *joint.samples[i];
            sample.local_position, ok = parse_vector3 (handler);
            if !ok
                return error_out(handler, "Could not parse joint local position.");
            sample.local_orientation, ok = parse_quaternion(handler);
            if !ok
                return error_out(handler, "Could not parse joint local orientation.");
            sample.local_scale, ok = parse_vector3 (handler);
            if !ok
                return error_out(handler, "Could not parse joint local scale.");
        }

        return true;
    }

    handler: Text_File_Handler;
    defer deinit(*handler);

    found_slash, dir, basename := split_from_right(filename, #char "/");
    if !found_slash
        basename = filename;
    start_file(*handler, basename, filename, optional = false);
    if handler.failed
        return false;

    if handler.version != 1
        return error_out(handler, "Invalid version number.");

    ok: bool;
    anim.joints.count, ok = parse_ident_and_int_line(*handler, "joint_count");
    if !ok
        return false;

    anim.sample_count, ok = parse_ident_and_int_line(*handler, "sample_count");
    if !ok
        return false;

    all_data := alloc(size_of(Joint_Animation) * anim.joints.count
        + size_of(Joint_Sample) * anim.sample_count * anim.joints.count);
    anim.joints.data = all_data;
    for * anim.joints {
        joint_data := all_data + size_of(Joint_Animation) * anim.joints.count
            + size_of(Joint_Sample) * anim.sample_count * it_index;
        if !parse_joint(*handler, anim, it, joint_data)
            return false;
    }

    return true;
}

/*
  {
    vertices        : [x1,y1,z1, x2,y2,z2, ...],                        // 3 coordinates per vertex
    weights         : [v1w1,v1w2,v1w3,v1w4, v2w1,v2w2,v2w3,v2w4, ...],  // 4 weights per vertex
    boneIndices     : [v1i1,v1i2,v1i3,v1i4, v2i1,v2i2,v2i3,v2i4, ...],  // 4 bone indices per vertex
    triangleIndices : [t1i1,t1i2,t1i3,  t2i1,t2i2,t2i3, ...],           // 3 vertex indices per triangle
    bones : [
      { name     : 'name',                           // bone name
        parent   : 'name',                           // name of parent bone
        position : [x,y,z],                          // rest position in parent coordinates
        rotation : [h,p,b],                          // rest rotation in parent coordinates 
        anim     : [[h,p,b],[h,p,b], ...],           // rotation animation (Euler)
        animT    : [[x,y,z],[x,y,z], ...],           // translation animation (optional)
      },
      ...
    ]
    anims : [
     { name: 'name', start: frame, stop: frame },
     ...
    ]
  }
*/

Json_Bone :: struct {
    name: string;
    parent: string;
    weightmap: s32;
    position: [..]float;
    rotation: [..]float;
    anim: [..][..]float;
    anim_t: [..][..]float; @JsonName(animT)
}

Json_Animation :: struct {
    name: string;
    start: s32;
    length: s32;
}

Json_Character :: struct {
    vertices: [..]float;
    normals: [..]float;
    indices: [..]u32; @JsonName(triangleIndices)
    weights: [..]float;
    bone_indices: [..]s16; @JsonName(boneIndices)
    bones: [..]Json_Bone;
    animations: [..]Json_Animation;
}

hpb_to_quaternion :: (hpb: Vector3) -> Quaternion {
    q_h: Quaternion;
    set_from_axis_and_angle(*q_h, 0, 1, 0, hpb.x);
    q_p: Quaternion;
    set_from_axis_and_angle(*q_p, 1, 0, 0, hpb.y);
    q_b: Quaternion;
    set_from_axis_and_angle(*q_b, 0, 0, 1, hpb.z);
    return q_h * q_p * q_b;
}

load_pga_mesh_from_file :: (mesh: *Skinned_Mesh, filename: string) -> bool {
    total_motor_for_skeleton_joint :: (j:*Skeleton.Joint) -> Motor {
        if j.parent == null {
            return j.local_origin_pos * j.local_origin_rot;
        } else {
            return total_motor_for_skeleton_joint(j.parent) * (j.local_origin_pos * j.local_origin_rot);
        }
    }

    ok, in := load_json_from_file(filename);
    if !ok  return false;

    mesh.joints.count = in.bones.count;
    mesh.vertices.count = in.vertices.count / 3;
    mesh.indices.count = in.indices.count;
    all_data := alloc(size_of(Skeleton.Joint) * mesh.joints.count
        + size_of(Vertex) * mesh.vertices.count
        + size_of(u32) * mesh.indices.count
    );
    init(*mesh.name_to_joint_id, mesh.joints.count);
    init(*mesh.joint_id_to_name, mesh.joints.count);
    mesh.joints.data   = all_data;
    mesh.vertices.data = cast(*Vertex) (mesh.joints.data + mesh.joints.count);
    mesh.indices.data  = cast(*u32) (mesh.vertices.data + mesh.vertices.count);

    for * mesh.joints {
        it.id = cast(s16)it_index;
        table_add(*mesh.name_to_joint_id, copy_string(in.bones[it_index].name), it.id);
        table_add(*mesh.joint_id_to_name, it.id, copy_string(in.bones[it_index].name));
    }
    for * mesh.vertices {
        // it is the vertex
        memcpy(*it.position, (in.vertices.data + it_index*3), size_of(float) * 3);
        memcpy(*it.normal, (in.normals.data + it_index*3), size_of(float) * 3);
        memcpy(*it.weights, (in.weights.data + it_index*4), size_of(float) * 3);
        memcpy(*it.joints, (in.bone_indices.data + it_index*4), size_of(s16) * 4);
    }
    memcpy(mesh.indices.data, in.indices.data, size_of(u32) * mesh.indices.count);

    for * mesh.joints {
        json_joint := in.bones[it_index];
        parent_name := json_joint.parent;
        if parent_name != "" {
            it.id = cast(s16)it_index;
            parent_id, ok := table_find(*mesh.name_to_joint_id, parent_name);
            it.parent = *mesh.joints[parent_id];
            my_name, _ := table_find(*mesh.joint_id_to_name, it.id);
        }
    }
    for * mesh.joints {
        json_joint := in.bones[it_index];

        q := hpb_to_quaternion(Vector3.{json_joint.rotation[0], json_joint.rotation[1], json_joint.rotation[2]});
        rmat := rotation_matrix(Matrix4, q);
	    tmat := make_translation_matrix4(Vector3.{json_joint.position[0], json_joint.position[1], json_joint.position[2]});
	    smat := make_scale_matrix4(Vector3.{1, 1, 1});
	    mat := tmat * smat * rmat;

        it.local_bind_transform = mat;

        {
            it.local_origin_pos = Translator.make(Vector3.{
                json_joint.position[0], 
                json_joint.position[1], 
                json_joint.position[2]
            });
            it.local_origin_rot = Rotor.make(q);
        }
    }
    for * mesh.joints {
        it.bind_pose = total_motor_for_skeleton_joint(it);
        it.bind_pose_inverse = ~it.bind_pose;
    }

    for *mesh.joints {
        if it.parent {
            it.inverse_bind_transform = it.parent.inverse_bind_transform * it.local_bind_transform;
        } else {
            it.inverse_bind_transform = it.local_bind_transform;
        }
    }
    for * mesh.joints
        it.inverse_bind_transform = inverse(it.inverse_bind_transform);

    return true;
}

load_json_from_file :: (filename: string) -> bool, Json_Character {
    ok, jcharacter := json_parse_file(filename, Json_Character);
    return ok, jcharacter;
}

load_pga_anims_from_file :: (skeleton: *Skeleton, filename: string) -> []Sampled_Animation {
    out: [..]Sampled_Animation;
    ok, in := load_json_from_file(filename);
    if !ok  return out;
    for in.animations {
        anim: Sampled_Animation;
        load_pga_anim_from_file(skeleton, *anim, it.name, *in);
        array_add(*out, anim);
    }
    return out;
}

load_pga_anim_from_file :: (skeleton: *Skeleton, anim: *Sampled_Animation, name: string, file: *Json_Character) {
    get_sample_position_for_animation_at_index :: (janim: *Json_Animation, joint_index: s32, sample_index_in_animation: s32, file: *Json_Character) -> Vector3 {
        start_index_of_animation := janim.start;
        total_index := start_index_of_animation + sample_index_in_animation;
        jbone := file.bones[joint_index];
        if jbone.anim_t.count >= (total_index + 1) {
            return Vector3.{ jbone.anim_t[total_index][0], jbone.anim_t[total_index][1], jbone.anim_t[total_index][2]};
        } else {
            return Vector3.{0, 0, 0};
        }
    }

    get_sample_rotation_for_animation_at_index :: (janim: *Json_Animation, joint_index: s32, sample_index_in_animation: s32, file: *Json_Character) -> Vector3 {
        start_index_of_animation := janim.start;
        total_index := start_index_of_animation + sample_index_in_animation;
        jbone := file.bones[joint_index];
        if jbone.anim.count >= (total_index + 1) {
            return Vector3.{ jbone.anim[total_index][0], jbone.anim[total_index][1], jbone.anim[total_index][2]};
        } else {
            return Vector3.{0, 0, 0};
        }
    }

    janim: Json_Animation;
    for file.animations {
        if it.name == name {
            janim = it;
        }
    }
    start := janim.start;
    length := janim.length;
    anim.joints.count = file.bones.count;
    anim.sample_count = length;
    all_data := alloc(size_of(Joint_Animation) * anim.joints.count
        + size_of(Joint_Sample) * anim.sample_count * anim.joints.count);
    anim.joints.data = all_data;
    for * joint_animation: anim.joints {
        joint_name, _ := table_find(*skeleton.joint_id_to_name, xx it_index);
        joint_index := it_index;
        joint_data := all_data + size_of(Joint_Animation) * anim.joints.count
            + size_of(Joint_Sample) * anim.sample_count * it_index;
        joint_animation.name = copy_string(file.bones[it_index].name);
        joint_animation.samples.data = joint_data;
        joint_animation.samples.count = anim.sample_count;

        joint_in_original_skeleton := skeleton.joints[joint_index];
        for i: 0..anim.sample_count - 1 {
            jsamplepos := get_sample_position_for_animation_at_index(*janim, xx joint_index, xx i, file);
            jsamplerot := get_sample_rotation_for_animation_at_index(*janim, xx joint_index, xx i, file);
            // print("anim=%, joint=%(%), sample=%: % %\n", name, joint_name, joint_index, i, jsamplepos, jsamplerot);

            outsample := *joint_animation.samples[i];
            // matrix
            {
                trans, rot, scale := decompose_transform(joint_in_original_skeleton.local_bind_transform);
                if joint_index > 0 {
                    outsample.local_position = trans + jsamplepos;
                } else {
                    outsample.local_position = jsamplepos;
                }
                outsample.local_orientation = rot * hpb_to_quaternion(jsamplerot);
                outsample.local_scale = Vector3.{1, 1, 1};
            }
            // pga
            {
                local_pos := Translator.make(jsamplepos);
                if joint_index > 0 {
                    local_pos = joint_in_original_skeleton.local_origin_pos * local_pos;
                } 
                local_rot := Rotor.make(hpb_to_quaternion(jsamplerot));
                local_rot = joint_in_original_skeleton.local_origin_rot * local_rot;
                outsample.keyframe_motor = local_pos * local_rot;
            }
        }
    }
    set_total_motor_for_animation(skeleton, anim);
}

set_total_motor_for_animation :: (skeleton: *Skeleton, anim: *Sampled_Animation) {
    total_keyframe_motor :: (joint_animation_index: s32, sample_animation_index: s32, skeleton: *Skeleton, anim: *Sampled_Animation) -> Motor {
        joint_in_animation := anim.joints[joint_animation_index];
        joint_in_skeleton := skeleton.joints[joint_animation_index];
        joint_parent_in_skeleton := joint_in_skeleton.parent;
        if joint_parent_in_skeleton == null {
            return joint_in_animation.samples[sample_animation_index].keyframe_motor;
        } else {
            //it has a parent, find the index of the parent in the animation
            parent_total_motor := total_keyframe_motor(
                joint_parent_in_skeleton.id, sample_animation_index, skeleton, anim);
            return 
                parent_total_motor * joint_in_animation.samples[sample_animation_index].keyframe_motor;
        }
        
    }
    for * joint_animation: anim.joints {
        for i: 0..anim.sample_count - 1 {
            joint_animation.samples[i].total_keyframe_motor = total_keyframe_motor(xx it_index, xx i, skeleton, anim);
        }
    }

}

make_pose_for_skeleton :: (skeleton: *Skeleton) -> Skeleton_Pose #must {
    pose: Skeleton_Pose;
    pose.skeleton = skeleton;
    pose.joints = NewArray(skeleton.joints.count, Skeleton_Pose.Joint);
    
    for *joint_in_pose: pose.joints {
        joint_in_skeleton := *skeleton.joints[it_index];
        if joint_in_skeleton.parent {
            parent_id := joint_in_skeleton.parent - skeleton.joints.data;
            joint_in_pose.parent = *pose.joints[parent_id];
        } else
            joint_in_pose.parent = null;
    }

    return pose;
}

free_pose :: (pose: *Skeleton_Pose) {
    free(pose.joints.data);
    free(pose.skinning_matrices.data);
    pose.skeleton = null;
    pose.joints = .[];
    pose.skinning_matrices = .[];
}

reset_to_bind_pose :: (using pose: *Skeleton_Pose) {
    for * joint_in_pose: joints {
        joint_in_pose.local_position, joint_in_pose.local_orientation, joint_in_pose.local_scale = decompose_transform(skeleton.joints[it_index].local_bind_transform);

        {
            // set the transform directly
            joint_in_pose.keyframe_motor = skeleton.joints[it_index].local_origin_pos * skeleton.joints[it_index].local_origin_rot;
            joint_in_pose.model_space_motor = skeleton.joints[it_index].bind_pose;
        }
    }
    update_total_motor(pose);
}

Interpolation_Mode :: enum s32 {
    NEAREST :: 0;
    LINEAR  :: 1;
    LINEAR_SLERP :: 2;
}

interpolate_joint_samples :: inline(
    pose: *Skeleton_Pose, 
    joint_index: s32, 
    a: Joint_Sample,
    b: Joint_Sample,
    t: float,
    interpolation_mode: Interpolation_Mode
) -> Joint_Sample #must {
    nlerp_shortest :: (a: Quaternion, b: Quaternion, t: float) -> Quaternion #must {
        first  := a;
        second := b;
        if dot(first, second) < 0
            second = -second;
        
        return nlerp(first, second, t);
    }

    slerp_shortest :: (a: Quaternion, b: Quaternion, t: float) -> Quaternion #must {
        first  := a;
        second := b;
        if dot(first, second) < 0
            second = -second;

        return slerp(first, second, t);
    }

    t = clamp(t, 0, 1);
    pose_joint_sample: Joint_Sample = ---;
    if #complete interpolation_mode == {
    case .NEAREST;
        if t < 0.5 then pose_joint_sample = a;
        else            pose_joint_sample = b;
        pose_joint_sample.local_scale       = lerp(a.local_scale, b.local_scale, t);
    case .LINEAR;
        pose_joint_sample.local_position       = lerp(a.local_position, b.local_position, t);
        pose_joint_sample.local_orientation    = nlerp_shortest(a.local_orientation, b.local_orientation, t);
        pose_joint_sample.local_scale          = lerp(a.local_scale, b.local_scale, t);

        pose_joint_sample.keyframe_motor       = nlerp(a.keyframe_motor, b.keyframe_motor, t);
        pose_joint_sample.total_keyframe_motor = nlerp(a.total_keyframe_motor, b.total_keyframe_motor, t);
    case .LINEAR_SLERP;
        pose_joint_sample.local_position    = lerp(a.local_position, b.local_position, t);
        pose_joint_sample.local_orientation = slerp_shortest(a.local_orientation, b.local_orientation, t);
        pose_joint_sample.local_scale       = lerp(a.local_scale, b.local_scale, t);

        pose_joint_sample.keyframe_motor       = slerp(a.keyframe_motor, b.keyframe_motor, t);
        pose_joint_sample.total_keyframe_motor = slerp(a.total_keyframe_motor, b.total_keyframe_motor, t);
    }
    return pose_joint_sample;
}

sample_animation :: (
    using anim: Sampled_Animation,
    time_in_samples: float,
    pose: *Skeleton_Pose,
    interpolation_mode := Interpolation_Mode.LINEAR
) {
    time_in_samples = fmod_cycling(time_in_samples, cast(float) sample_count);
    first_index  := cast(s64) time_in_samples;
    second_index := (first_index + 1) % sample_count;
    for joint: joints {
        joint_index, ok := table_find(*pose.skeleton.name_to_joint_id, joint.name);
        if !ok
            continue;
        first  := joint.samples[first_index];
        second := joint.samples[second_index];
        pose.joints[joint_index].sample = interpolate_joint_samples(
            pose, joint_index, 
            first,
            second,
            time_in_samples - first_index,
            interpolation_mode
        );
    }
}

update_total_motor:: (using pose: *Skeleton_Pose) {
    total_keyframe_motor :: (s: *Skeleton, j:*Skeleton_Pose.Joint) -> Motor {
        if j.parent == null {
            return j.keyframe_motor;
        } else {
            motor := total_keyframe_motor(s, j.parent);
            return motor * j.keyframe_motor;
        }
    }
    for * pose_joint: pose.joints {
        pose_joint.total_keyframe_motor = total_keyframe_motor(skeleton, pose_joint);
    }
}

calculate_pose_transforms :: (using pose: *Skeleton_Pose) {
    total_motor_for_skeleton_pose_joint_2 :: (s: *Skeleton, j:*Skeleton_Pose.Joint) -> Motor {
        if j.parent == null {
            return j.keyframe_motor;
        } else {
            return total_motor_for_skeleton_pose_joint_2(s, j.parent) * j.keyframe_motor;;
        }
    }
    for * joints {
        local_transform := make_translation_matrix4 (it.local_position)
            * make_scale_matrix4 (it.local_scale)
            * rotation_matrix(Matrix4, it.local_orientation);

        parent := it.parent;
        if parent
            it.model_space_transform = parent.model_space_transform * local_transform;
        else
            it.model_space_transform = local_transform;
    }
    for * pose_joint: pose.joints {
        motor := pose_joint.total_keyframe_motor;//total_motor_for_skeleton_pose_joint_2(skeleton, pose_joint);
        pose_joint.model_space_motor = motor;
    }
}

generate_skinning_matrices :: (using pose: *Skeleton_Pose, transpose_result: bool) {
    calculate_pose_transforms(pose);
    if !skinning_matrices.data
        skinning_matrices = NewArray(joints.count, Matrix4, initialized = false);
    // The skinning matrices array isn't allocated as long as you don't call this function.
    for i: 0..skinning_matrices.count - 1 {
        skinning_matrices[i] = joints[i].model_space_transform * skeleton.joints[i].inverse_bind_transform;
    }
    for i: 0..skinning_matrices.count - 1 {
        if transpose_result
            transpose(*skinning_matrices[i]);
    }
    if !skinning_matrices_pga.data
        skinning_matrices_pga = NewArray(joints.count, Matrix4, initialized = false);
    for i: 0..skinning_matrices_pga.count - 1 {
        skinning_matrices_pga[i] = matrix4x4(joints[i].model_space_motor * skeleton.joints[i].bind_pose_inverse);
    }
    for i: 0..skinning_matrices_pga.count - 1 {
        if transpose_result
            transpose(*skinning_matrices_pga[i]);
    }
}
