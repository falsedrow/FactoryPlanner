local function open_tutorial_dialog(player, modal_data)
    local function add_base_frame(name)
        local frame = modal_data.modal_elements.content_frame.add{type="frame",
            style="bordered_frame", direction="vertical"}
        frame.style.width = 550

        frame.add{type="label", caption={"fp." .. name .. "_tutorial_title"}, style="caption_label"}
        local label_text = frame.add{type="label", caption={"fp." .. name .. "_tutorial_text"}}
        label_text.style.single_line = false

        return frame
    end

    -- Interactive tutorial
    local frame_interactive = add_base_frame("interactive")
    local flow_interactive = frame_interactive.add{type="flow", direction="horizontal"}
    flow_interactive.style.margin = {12, 20, 8, 20}

    flow_interactive.add{type="empty-widget", style="flib_horizontal_pusher"}

    -- If the tutorial factory is valid, it can be imported regardless of the current modset
    local factory_valid = (global.tutorial_factory ~= nil and global.tutorial_factory.valid)
    local button_tooltip = (not factory_valid) and {"fp.warning_message", {"fp.create_example_error"}} or nil
    flow_interactive.add{type="button", tags={mod="fp", on_gui_click="add_example_factory"},
        caption={"fp.create_example"}, tooltip=button_tooltip, enabled=factory_valid, mouse_button_filter={"left"}}

    flow_interactive.add{type="empty-widget", style="flib_horizontal_pusher"}

    local tutorial_mode = util.globals.preferences(player).tutorial_mode
    util.gui.switch.add_on_off(flow_interactive, "toggle_tutorial_mode", {}, tutorial_mode,
        {"fp.tutorial_mode"}, nil, true)

    flow_interactive.add{type="empty-widget", style="flib_horizontal_pusher"}

    -- Interface tutorial
    local frame_interface = add_base_frame("interface")
    local recipebook_string = (RECIPEBOOK_ACTIVE) and {"fp.interface_controls_recipebook"} or ""
    local label_controls = frame_interface.add{type="label", caption={"", {"fp.interface_controls"}, recipebook_string}}
    label_controls.style.single_line = false
    label_controls.style.margin = {6, 0, 0, 6}
end


-- ** EVENTS **
local listeners = {}

listeners.gui = {
    on_gui_click = {
        {
            name = "add_example_factory",
            timeout = 20,
            handler = (function(player, _, _)
                -- If this button can be pressed, the tutorial factory is valid implicitly
                local player_table = util.globals.player_table(player)
                local clone = global.tutorial_factory:clone()
                player_table.district:insert(clone)
                solver.update(player, clone)
                util.context.set(player, clone)

                util.raise.refresh(player, "all", nil)
                util.raise.close_dialog(player, "cancel")
            end)
        }
    },
    on_gui_switch_state_changed = {
        {
            name = "toggle_tutorial_mode",
            handler = (function(player, _, event)
                local preferences = util.globals.preferences(player)
                preferences.tutorial_mode = util.gui.switch.convert_to_boolean(event.element.switch_state)
                util.raise.refresh(player, "all", nil)
            end)
        }
    }
}

listeners.dialog = {
    dialog = "tutorial",
    metadata = (function(_) return {
        caption = {"fp.tutorial"},
        create_content_frame = true
    } end),
    open = open_tutorial_dialog
}

return { listeners }
