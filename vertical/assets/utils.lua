local M = {}

function M.play_sound(id)
	msg.post("#" .. id, "play_sound")
end

return M