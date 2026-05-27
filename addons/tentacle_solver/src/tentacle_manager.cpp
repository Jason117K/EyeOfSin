#include "tentacle_manager.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <cmath>

using namespace godot;

TentacleManager::TentacleManager() {
}

TentacleManager::~TentacleManager() {
}

void TentacleManager::_bind_methods() {
	ClassDB::bind_method(D_METHOD("register_arm", "arm_node"), &TentacleManager::register_arm);
	ClassDB::bind_method(D_METHOD("unregister_arm", "arm_id"), &TentacleManager::unregister_arm);
	ClassDB::bind_method(D_METHOD("get_solved_segments", "arm_id"), &TentacleManager::get_solved_segments);
	ClassDB::bind_method(D_METHOD("get_active_arm_count"), &TentacleManager::get_active_arm_count);
	ClassDB::bind_method(D_METHOD("solve_single", "segments", "target", "segment_length",
								   "ik_iters", "constraint_iters", "enable_constraints"),
			&TentacleManager::solve_single);
}

void TentacleManager::_notification(int p_what) {
	if (p_what == NOTIFICATION_READY) {
		set_physics_process(true);
		set_physics_process_priority(-100);
	} else if (p_what == NOTIFICATION_PHYSICS_PROCESS) {
		_process_tentacles(get_physics_process_delta_time());
	}
}

// ---------------------------------------------------------------------------
// Registration
// ---------------------------------------------------------------------------

int TentacleManager::register_arm(Node2D *p_arm) {
	if (!p_arm) {
		return -1;
	}

	int id = _next_id++;
	ArmData data;
	data.arm_instance_id = p_arm->get_instance_id();
	_refresh_arm_params(data, p_arm);
	_initialize_arm_segments(data);
	_arms[id] = data;
	return id;
}

void TentacleManager::unregister_arm(int p_id) {
	_arms.erase(p_id);
}

PackedVector2Array TentacleManager::get_solved_segments(int p_id) const {
	if (!_arms.has(p_id)) {
		return PackedVector2Array();
	}
	return _arms[p_id].segments;
}

int TentacleManager::get_active_arm_count() const {
	return _arms.size();
}

// ---------------------------------------------------------------------------
// Per-frame processing
// ---------------------------------------------------------------------------

void TentacleManager::_process_tentacles(double p_delta) {
	Vector<int> stale;

	for (KeyValue<int, ArmData> &kv : _arms) {
		ArmData &data = kv.value;

		Node2D *arm = _get_node2d_by_id(data.arm_instance_id);
		if (!arm || !arm->is_inside_tree()) {
			stale.push_back(kv.key);
			continue;
		}

		_refresh_arm_params(data, arm);

		int expected_size = data.num_segments + 1;
		if (data.segments.size() != expected_size) {
			_initialize_arm_segments(data);
		}

		// Resolve target position
		Vector2 target_global;
		Variant target_var = arm->get("target");
		if (target_var.get_type() == Variant::OBJECT) {
			Node2D *target_node = Object::cast_to<Node2D>((Object *)target_var);
			if (target_node && target_node->is_inside_tree()) {
				target_global = target_node->get_global_position();
			} else {
				target_global = arm->get_global_mouse_position();
			}
		} else {
			target_global = arm->get_global_mouse_position();
		}

		Vector2 target_local = arm->to_local(target_global);
		_solve_arm(data, target_local, p_delta);
	}

	for (int i = 0; i < stale.size(); i++) {
		_arms.erase(stale[i]);
	}
}

void TentacleManager::_refresh_arm_params(ArmData &r_data, Node2D *p_arm) {
	r_data.num_segments = (int)(int64_t)p_arm->get("num__segments");
	r_data.max_length = (float)(double)p_arm->get("max_length");
	r_data.ik_iterations = (int)(int64_t)p_arm->get("ik_iterations");
	r_data.constraint_iterations = (int)(int64_t)p_arm->get("constraint_iterations");
	r_data.enable_constraints = (bool)p_arm->get("enable_contraint");
	r_data.wave_amplitude = (float)(double)p_arm->get("wave_amplitude");
	r_data.wave_frequency = (float)(double)p_arm->get("wave_frequency");
	r_data.wave_speed = (float)(double)p_arm->get("wave_speed");
}

void TentacleManager::_initialize_arm_segments(ArmData &r_data) {
	r_data.segments.clear();
	r_data.segment_lengths.clear();

	Vector2 base_pos = Vector2(0.0f, 0.0f);
	r_data.segments.push_back(base_pos);

	r_data.total_length = 0.0f;
	float seg_len = r_data.max_length / (float)r_data.num_segments;

	for (int i = 0; i < r_data.num_segments; i++) {
		r_data.segment_lengths.push_back(seg_len);
		r_data.total_length += seg_len;
		r_data.segments.push_back(base_pos + Vector2(seg_len * (float)(i + 1), 0.0f));
	}

	r_data.wave_time = 0.0f;
	r_data.initialized = true;
}

// ---------------------------------------------------------------------------
// Solver — direct port from Arm.gd
// ---------------------------------------------------------------------------

void TentacleManager::_solve_arm(ArmData &r_data, Vector2 p_target_local, double p_delta) {
	if (!r_data.initialized || r_data.segments.size() < 2) {
		return;
	}

	Vector2 *seg = r_data.segments.ptrw();
	const float *len = r_data.segment_lengths.ptr();
	int n = r_data.num_segments;
	Vector2 base(0.0f, 0.0f);

	_solve_ik(seg, len, p_target_local, base, n, r_data.ik_iterations);

	if (r_data.enable_constraints) {
		_apply_constraints(seg, len, base, n, r_data.constraint_iterations);
	}

	if (r_data.wave_amplitude > 0.0f) {
		r_data.wave_time += (float)p_delta * r_data.wave_speed;
		_apply_wave_motion(seg, len, n, r_data.wave_time, r_data.total_length,
				r_data.wave_amplitude, r_data.wave_frequency);
	}

	if (r_data.enable_constraints) {
		_apply_constraints(seg, len, base, n, r_data.constraint_iterations);
	}
}

void TentacleManager::_solve_ik(
		Vector2 *p_seg, const float *p_len,
		Vector2 p_target, Vector2 p_base,
		int p_num_seg, int p_ik_iters) {
	p_seg[p_num_seg] = p_target;

	for (int iter = 0; iter < p_ik_iters; iter++) {
		// Backward pass — tip is anchored, base drifts
		for (int i = p_num_seg - 1; i >= 0; i--) {
			Vector2 vec = p_seg[i] - p_seg[i + 1];
			float mag = vec.length();
			if (mag < 0.0001f) {
				p_seg[i] = p_seg[i + 1] + Vector2(p_len[i], 0.0f);
			} else {
				p_seg[i] = p_seg[i + 1] + (vec / mag) * p_len[i];
			}
		}

		// Forward pass — re-anchor base, tip drifts slightly
		p_seg[0] = p_base;
		for (int i = 0; i < p_num_seg; i++) {
			Vector2 vec = p_seg[i + 1] - p_seg[i];
			float mag = vec.length();
			if (mag < 0.0001f) {
				p_seg[i + 1] = p_seg[i] + Vector2(p_len[i], 0.0f);
			} else {
				p_seg[i + 1] = p_seg[i] + (vec / mag) * p_len[i];
			}
		}
	}
}

void TentacleManager::_apply_constraints(
		Vector2 *p_seg, const float *p_len,
		Vector2 p_base, int p_num_seg, int p_constraint_iters) {
	p_seg[0] = p_base;

	for (int iter = 0; iter < p_constraint_iters; iter++) {
		for (int i = 0; i < p_num_seg; i++) {
			Vector2 current_vec = p_seg[i + 1] - p_seg[i];
			float distance = current_vec.length();

			if (distance < 0.0001f) {
				p_seg[i + 1] = p_seg[i] + Vector2(p_len[i], 0.0f);
				continue;
			}

			// Reuse computed length instead of calling normalized() — saves one sqrt
			Vector2 target_vec = current_vec * (p_len[i] / distance);
			Vector2 error_vec = target_vec - current_vec;

			if (i > 0) {
				p_seg[i] -= error_vec * 0.25f;
			}
			p_seg[i + 1] += error_vec * 0.25f;
		}

		p_seg[0] = p_base;
	}
}

void TentacleManager::_apply_wave_motion(
		Vector2 *p_seg, const float *p_len,
		int p_num_seg, float p_wave_time, float p_total_length,
		float p_amplitude, float p_frequency) {
	if (p_total_length < 0.0001f) {
		return;
	}

	float accumulated = 0.0f;
	int seg_count = p_num_seg + 1;

	for (int i = 1; i < seg_count; i++) {
		accumulated += p_len[i - 1];
		float t = accumulated / p_total_length;

		Vector2 vec = p_seg[i] - p_seg[i - 1];
		float mag = vec.length();
		Vector2 perp;

		if (mag < 0.0001f) {
			perp = Vector2(0.0f, 1.0f);
		} else {
			Vector2 dir = vec / mag;
			perp = Vector2(-dir.y, dir.x);
		}

		float phase = p_wave_time + t * p_frequency * Math_TAU;
		float offset = sinf(phase) * p_amplitude;
		p_seg[i] += perp * offset;
	}
}

// ---------------------------------------------------------------------------
// Utility
// ---------------------------------------------------------------------------

Node2D *TentacleManager::_get_node2d_by_id(uint64_t p_id) {
	Variant v = UtilityFunctions::instance_from_id(p_id);
	if (v.get_type() == Variant::NIL) {
		return nullptr;
	}
	return Object::cast_to<Node2D>((Object *)v);
}

PackedVector2Array TentacleManager::solve_single(
		PackedVector2Array p_segments,
		Vector2 p_target,
		float p_segment_length,
		int p_ik_iters,
		int p_constraint_iters,
		bool p_enable_constraints) {
	int num_seg = p_segments.size() - 1;
	if (num_seg < 1) {
		return p_segments;
	}

	PackedFloat32Array lengths;
	for (int i = 0; i < num_seg; i++) {
		lengths.push_back(p_segment_length);
	}

	Vector2 *seg = p_segments.ptrw();
	const float *len = lengths.ptr();
	Vector2 base(0.0f, 0.0f);

	_solve_ik(seg, len, p_target, base, num_seg, p_ik_iters);

	if (p_enable_constraints) {
		_apply_constraints(seg, len, base, num_seg, p_constraint_iters);
	}

	return p_segments;
}
