---@diagnostic disable

local migration = {}

function migration.packed_factory(packed_subfactory)
    local function update_lines(floor)
        for _, packed_line in ipairs(floor.Line.objects) do
            if packed_line.subfloor then
                update_lines(packed_line.subfloor)
            else
                packed_line.done = false

                packed_line.machine.force_limit = packed_line.machine.hard_limit
                packed_line.machine.hard_limit = nil
            end
        end
    end
    update_lines(packed_subfactory.top_floor)
end

return migration
