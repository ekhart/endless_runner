local M = {}

M.prop = {}
M.msg = {}
M.msg.recv = {}


M.prop.speed = "speed"

M.msg.set_speed = "set_speed"
M.msg.add_speed = "add_speed"
M.msg.add_point = "add_point"
M.msg.construct = "construct"

M.msg.recv.controller = "level:/controller#script"

return M