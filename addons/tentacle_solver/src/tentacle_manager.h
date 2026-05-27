#ifndef TENTACLE_MANAGER_H
#define TENTACLE_MANAGER_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/templates/hash_map.hpp>
#include <godot_cpp/templates/vector.hpp>

namespace godot {

class TentacleManager : public Node {
	GDCLASS(TentacleManager, Node)

public:
	TentacleManager();
	~TentacleManager();

	int register_arm(Node2D *p_arm);
	void unregister_arm(int p_id);
	PackedVector2Array get_solved_segments(int p_id) const;
	int get_active_arm_count() const;

	PackedVector2Array solve_single(
			PackedVector2Array p_segments,
			Vector2 p_target,
			float p_segment_length,
			int p_ik_iters,
			int p_constraint_iters,
			bool p_enable_constraints);

protected:
	static void _bind_methods();
	void _notification(int p_what);

private:
	struct ArmData {
		uint64_t arm_instance_id = 0;

		int num_segments = 24;
		float max_length = 128.0f;
		int ik_iterations = 2;
		int constraint_iterations = 10;
		bool enable_constraints = true;
		float wave_amplitude = 2.5f;
		float wave_frequency = 2.0f;
		float wave_speed = 3.0f;

		PackedVector2Array segments;
		PackedFloat32Array segment_lengths;
		float wave_time = 0.0f;
		float total_length = 0.0f;
		bool initialized = false;
	};

	HashMap<int, ArmData> _arms;
	int _next_id = 0;

	void _process_tentacles(double p_delta);
	void _refresh_arm_params(ArmData &r_data, Node2D *p_arm);
	void _initialize_arm_segments(ArmData &r_data);
	void _solve_arm(ArmData &r_data, Vector2 p_target_local, double p_delta);

	static Node2D *_get_node2d_by_id(uint64_t p_id);

	static void _solve_ik(
			Vector2 *p_seg, const float *p_len,
			Vector2 p_target, Vector2 p_base,
			int p_num_seg, int p_ik_iters);

	static void _apply_constraints(
			Vector2 *p_seg, const float *p_len,
			Vector2 p_base, int p_num_seg, int p_constraint_iters);

	static void _apply_wave_motion(
			Vector2 *p_seg, const float *p_len,
			int p_num_seg, float p_wave_time, float p_total_length,
			float p_amplitude, float p_frequency);
};

} // namespace godot

#endif // TENTACLE_MANAGER_H
