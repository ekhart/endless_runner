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

function M.click_button(domain, node, action, after)
	if gui.pick_node(gui.get_node(node), action.x, action.y) then
		msg.post(domain .. ":/hud#button", "play_sound")
		after()
	end
end

return M