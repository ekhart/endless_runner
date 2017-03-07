local M = {}

function M.play_sound(id)
	msg.post("#" .. id, "play_sound")
end

function M.play_sprite_animation(animation)
  msg.post("#sprite", "play_animation", { id = hash(animation) })
end

function M.is_id(id, to_hash)
  return id == hash(to_hash)
end

function M.click_button(domain, name, action, after)
	local node = gui.get_node(name)
	if gui.pick_node(node, action.x, action.y) then
		msg.post(domain .. ":/hud#button", "play_sound")
		gui.animate(node, gui.PROP_COLOR, vmath.vector4(), gui.EASING_INOUTQUAD, 0.5, 0, after, gui.PLAYBACK_ONCE_FORWARD)
	end
end

function M.post_current(message_id)
	msg.post(".", message_id)
end

function M.acquire_input_focus()
	M.post_current("acquire_input_focus")
end

function M.release_input_focus()
	M.post_current("release_input_focus")
end

function M.set_node_text(node, text)
	gui.set_text(gui.get_node(node), text)
end

function M.set_node_text(node, format_text, parameter)
	gui.set_text(gui.get_node(node), string.format(format_text, parameter))
end

function M.on_input(self, action_id, action, handle_input)
  local is_mouse_pressed = M.is_id(action_id, "left_button") and action.pressed 
  local is_touched = M.is_id(action_id, "touch") and #action.touch > 1

  if is_mouse_pressed then
    handle_input(action)
  elseif is_touched then
    for i, point in ipairs(action.touch) do
      handle_input(action)
    end
  end
end


return M