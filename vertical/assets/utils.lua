local M = {}

function M.play_sound(id)
	msg.post("#" .. id, "play_sound")
end

function M.get_random_animation(animations)
	local random_index = math.random(#animations)
	return animations[random_index]
end

function M.play_animation(id, animation)
  	msg.post(id .. "#sprite", "play_animation", { id = hash(animation) })
end

function M.play_sprite_animation(animation)
	M.play_animation("", animation)
end

function M.set_sprite_random_animation(animations)
	M.play_animation("", M.get_random_animation(animations)) 
end

function M.set_random_animation(id, animations)
	M.play_sprite_animation(id, M.get_random_animation(animations)) 
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

function M.set_position(change)
  local pos = go.get_position()
  change(pos)
  go.set_position(pos)
end

-- function M.set_position(id, change)
--   local pos = go.get_position(id)
--   change(pos)
--   go.set_position(pos, id)
-- end

function M.set_scale(size)
  local scale = go.get_scale()
  scale = vmath.vector3(size, size, 1.0)
  go.set_scale(scale)
end

function M.debug(text, x, y)
	local message = {text = text, position = vmath.vector3(x, y, 0)}
	msg.post("@render:", "draw_text", message)
end

function M.construct(self, message, after)
	self.speed = self.speed +  message.speed_up_size_accumulator
	self.size = go.get("#", "size")  
	M.set_scale(self.size)
	after(self, message)
end

function M.update_without_floor_delete_below(self, dt, delete_message_id, posy, change)
	M.set_position(function (pos)
    	if pos.y < posy then
      		msg.post("level:/controller#script", delete_message_id, { id = go.get_id() })
    	end
    	change(pos)
	end)
end

function M.update_without_floor(self, dt, delete_message_id, posy)
	M.update_without_floor_delete_below(self, dt, delete_message_id, -200, function(pos)
		pos.y = pos.y - self.speed
	end)
end

function M.update_delete_below(self, dt, delete_message_id, posy)
	M.update_without_floor_delete_below(self, dt, delete_message_id, posy, function(pos)
		pos.y = math.floor(pos.y - self.speed)
	end)
end

function M.update(self, dt, delete_message_id)
	M.update_delete_below(self, dt, delete_message_id, -200)
end

function M.disable(id)
	msg.post("#" .. id, "disable")
end

function M.enable(id)
	msg.post("#" .. id, "enable")
end

function M.spawn(self, factory_id, pos, objects, message)
	self.gridw = self.gridw + self.speed

	if self.gridw >= self.spawn_density then
		self.gridw = 0
		
		if math.random() > self.spawn_probability then
			local object = factory.create("#" .. factory_id, pos, nil, {})
			msg.post(object, "construct", message)
			table.insert(objects, object)
		end
	end
end

function M.get(prop)
	return go.get("#", prop)
end

return M