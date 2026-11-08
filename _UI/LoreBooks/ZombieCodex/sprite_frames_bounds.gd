class_name SpriteFramesBounds
extends RefCounted
## Visible-pixel bounds of a SpriteFrames animation, measured from each frame's center (how
## a centered AnimatedSprite2D draws, so frames of different sizes line up). Cached for the
## session, because reading a sheet back from the GPU is slow on big sheets.

const FALLBACK_SIZE := Vector2(32, 32)

static var _cache: Dictionary = {}


static func visible_rect(frames: SpriteFrames, animation: StringName) -> Rect2:
	var key := "%d:%s" % [frames.get_instance_id(), animation]
	if not _cache.has(key):
		_cache[key] = _measure(frames, animation)
	return _cache[key]


## Falls back to the full frames when no pixel data is available (headless dummy renderer).
static func _measure(frames: SpriteFrames, animation: StringName) -> Rect2:
	if not frames.has_animation(animation):
		push_warning("SpriteFramesBounds: '%s' has no animation '%s'" % [frames.resource_path, animation])
		return Rect2(-FALLBACK_SIZE / 2.0, FALLBACK_SIZE)
	var sheets := {}
	var visible := Rect2()
	var whole_frames := Rect2()
	var has_visible := false
	var has_frames := false
	for i: int in frames.get_frame_count(animation):
		var texture := frames.get_frame_texture(animation, i)
		if texture == null:
			continue
		var half := texture.get_size() / 2.0
		var frame_rect := Rect2(-half, texture.get_size())
		whole_frames = frame_rect if not has_frames else whole_frames.merge(frame_rect)
		has_frames = true
		var used := _used_rect(texture, sheets)
		if used.has_area():
			var used_rect := Rect2(Vector2(used.position) - half, used.size)
			visible = used_rect if not has_visible else visible.merge(used_rect)
			has_visible = true
	if has_visible:
		return visible
	return whole_frames if has_frames else Rect2(-FALLBACK_SIZE / 2.0, FALLBACK_SIZE)


static func _used_rect(texture: Texture2D, sheets: Dictionary) -> Rect2i:
	var atlas_texture := texture as AtlasTexture
	var source := atlas_texture.atlas if atlas_texture != null else texture
	if source == null:
		return Rect2i()
	if not sheets.has(source):
		sheets[source] = _read_image(source)
	var image: Image = sheets[source]
	if image == null:
		return Rect2i()
	if atlas_texture == null:
		return image.get_used_rect()
	var region := Rect2i(atlas_texture.region).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	if not region.has_area():
		return Rect2i()
	return image.get_region(region).get_used_rect()


static func _read_image(texture: Texture2D) -> Image:
	var image := texture.get_image()
	if image == null or image.is_empty():
		return null
	if image.is_compressed():
		image.decompress()
	return image
