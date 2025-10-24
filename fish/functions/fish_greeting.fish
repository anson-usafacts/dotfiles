function fish_greeting
    set_color blue
    echo "🐟  Hello, "(whoami)"!"
    set_color yellow
    echo "📅  "(date "+%a, %b %d %Y")"  ⏰ "(date "+%H:%M")
    set_color magenta
    echo "💻  Uptime: "(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
    set_color normal
end
