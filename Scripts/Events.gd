extends Node

# Put here all the signals
# To emit signals from a node, call Events.emit_signal("[action_in_past]_signal")
# To receive signals in a node, call connect(Events, "[action_in_past]_signal", node, "_on_[slot name]")

# InGame Signals
signal place_ladder_signal
signal ladder_placed_signal
signal ladder_not_placed_signal
signal rope_handled_signal
signal throw_rope_signal
signal rope_thrown_signal
signal objective_reached_signal
signal exit_reached_signal
signal player_enter_jump_state_signal
signal player_exit_jump_state_signal
signal victory_signal

# Menus Signals
signal button_pressed_signal
signal level_selected_signal
signal set_paused_signal
