local lexers = vis.lexers

local c = {
  bg0        = "#0d0c0c",
  bg1        = "#181616",
  bg2        = "#1d1b1b",
  bg3        = "#282727",
  bg4        = "#2d2b2b",
  bg5        = "#363434",
  fg         = "#c5c9c5",
  fg_dim     = "#a6a69c",
  gray       = "#727169",
  red        = "#c4746e",
  green      = "#8a9a7b",
  yellow     = "#c4b28a",
  blue       = "#8ba4b0",
  magenta    = "#a292a3",
  cyan       = "#8ea4a2",
  orange     = "#b6927b",
  violet     = "#8992a7",
  salmon     = "#b98d7b",
  white      = "#c5c9c5",
  spring_g   = "#8b9d7b",
  spring_b   = "#7e9b8f",
  winter_b   = "#6e8ba0",
  autumn_r   = "#c47b6e",
  autumn_g   = "#9b9b7b",
  autumn_y   = "#bfa67a",
  samurai_r  = "#b3686e",
}

lexers.STYLE_DEFAULT              = "fore:" .. c.fg .. ",back:" .. c.bg1
lexers.STYLE_NOTHING              = ""
lexers.STYLE_ATTRIBUTE            = "fore:" .. c.spring_g
lexers.STYLE_CLASS                = "fore:" .. c.yellow .. ",bold"
lexers.STYLE_COMMENT              = "fore:" .. c.gray
lexers.STYLE_CONSTANT             = "fore:" .. c.cyan
lexers.STYLE_DEFINITION           = "fore:" .. c.blue
lexers.STYLE_ERROR                = "fore:" .. c.red .. ",italics"
lexers.STYLE_FUNCTION             = "fore:" .. c.blue .. ",bold"
lexers.STYLE_HEADING              = "fore:" .. c.magenta
lexers.STYLE_KEYWORD              = "fore:" .. c.magenta
lexers.STYLE_LABEL                = "fore:" .. c.spring_g
lexers.STYLE_NUMBER               = "fore:" .. c.orange
lexers.STYLE_OPERATOR             = "fore:" .. c.cyan
lexers.STYLE_REGEX                = "fore:" .. c.spring_g
lexers.STYLE_STRING               = "fore:" .. c.spring_b
lexers.STYLE_PREPROCESSOR         = "fore:" .. c.violet
lexers.STYLE_TAG                  = "fore:" .. c.red
lexers.STYLE_TYPE                 = "fore:" .. c.spring_g
lexers.STYLE_VARIABLE             = "fore:" .. c.blue
lexers.STYLE_WHITESPACE           = ""
lexers.STYLE_EMBEDDED             = "back:" .. c.bg3
lexers.STYLE_IDENTIFIER           = "fore:" .. c.fg

lexers.STYLE_LINENUMBER           = "fore:" .. c.gray .. ",back:" .. c.bg0
lexers.STYLE_LINENUMBER_CURSOR    = "fore:" .. c.fg_dim .. ",back:" .. c.bg3
lexers.STYLE_CURSOR               = "back:" .. c.fg .. ",fore:" .. c.bg1
lexers.STYLE_CURSOR_PRIMARY       = "back:" .. c.white .. ",fore:" .. c.bg1
lexers.STYLE_CURSOR_LINE          = "back:" .. c.bg2
lexers.STYLE_COLOR_COLUMN         = "back:" .. c.bg3
lexers.STYLE_SELECTION            = "back:" .. c.bg4
lexers.STYLE_STATUS               = "fore:" .. c.fg_dim .. ",back:" .. c.bg3
lexers.STYLE_STATUS_FOCUSED       = "fore:" .. c.fg .. ",back:" .. c.bg4 .. ",bold"
lexers.STYLE_SEPARATOR            = lexers.STYLE_DEFAULT
lexers.STYLE_INFO                 = "bold"
lexers.STYLE_EOF                  = "fore:" .. c.gray

lexers.STYLE_ADDITION             = "fore:" .. c.green
lexers.STYLE_DELETION             = "fore:" .. c.red
lexers.STYLE_CHANGE               = "fore:" .. c.yellow

lexers.STYLE_PROPERTY             = lexers.STYLE_ATTRIBUTE
lexers.STYLE_PSEUDOCLASS          = ""
lexers.STYLE_PSEUDOELEMENT        = ""

lexers.STYLE_TAG_UNKNOWN          = lexers.STYLE_TAG .. ",italics"
lexers.STYLE_ATTRIBUTE_UNKNOWN    = lexers.STYLE_ATTRIBUTE .. ",italics"
