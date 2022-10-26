name = get_application_name():lower()
class = get_window_class():lower()

if class == "gjs" then return
elseif class == "alacritty" then set_window_workspace(1)
elseif name == "firefox" then set_window_workspace(2)
elseif class == "discord" then set_window_workspace(3)
elseif class == "slack" then set_window_workspace(3)
elseif class == "signal" then set_window_workspace(3)
elseif name == "keepassxc" then set_window_workspace(4)
else print(string.format("Unmapped window name=%s class=%s", name, class))
end
