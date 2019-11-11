# Autogenerated config.py
# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

# Uncomment this to still load settings configured via autoconfig.yml
# config.load_autoconfig()

# This setting can be used to map keys to other keys. When the key used
# as dictionary-key is pressed, the binding for the key used as
# dictionary-value is invoked instead. This is useful for global
# remappings of keys, for example to map Ctrl-[ to Escape. Note that
# when a key is bound (via `bindings.default` or `bindings.commands`),
# the mapping is ignored.
# Type: Dict
c.bindings.key_mappings = {
    '<Ctrl-[>': '<Escape>',
    '<Ctrl-6>': '<Ctrl-^>',
    '<Ctrl-M>': '<Return>',
    '<Ctrl-J>': '<Return>',
    '<Shift-Return>': '<Return>',
    '<Enter>': '<Return>',
    '<Shift-Enter>': '<Return>',
    '<Ctrl-Enter>': '<Ctrl-Return>',
}

# Minimum logical font size (in pixels) that is applied when zooming
# out.
# Type: Int
c.fonts.web.size.minimum_logical = 0

# Bindings for normal mode
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')

c.downloads.location.directory = "~/downloads"

c.url.searchengines = {
    "DEFAULT": "https://google.co.uk/search?q={}",
    "yt": "https://www.youtube.com/results?search_query={}",
    "sch": "https://scholar.google.co.uk/scholar?hl=en&q={}"
}
c.url.default_page = "https://google.co.uk"
c.url.start_pages = "https://google.co.uk"

c.qt.args = ["ppapi-widevine-path=/opt/google/chrome/libwidevinecdm.so"]

c.aliases = {
    "w": "session-save",
    "q": "quit",
    "wq": "quit --save",
    "tf": "tab-focus",
    "od": "download-open",
    "cd": "download-clear"
}
