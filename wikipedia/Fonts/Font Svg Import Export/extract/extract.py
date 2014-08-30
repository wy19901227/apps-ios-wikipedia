#!/usr/local/bin/fontforge

# Extracts svgs from "./font.ttf"
# Invoke with command:
#    fontforge -lang=ff -script extract.py

# Scripting methods: 
#    http://fontforge.org/scripting.html

# GlyphInfo docs:
#    http://stderr.org/doc/fontforge/html/scripting-alpha.html#GlyphInfo

Open("font.ttf")

svgFolder = "./extracted svgs/"

SelectWorthOutputting()
foreach
    char = GlyphInfo("Unicode")
    if(char != -1)
        lBearing = Int(GlyphInfo("LBearing"))
        rBearing = Int(GlyphInfo("RBearing"))
        minY = Int(GlyphInfo("BBox")[1])
        formatString = svgFolder + "%u %n " + lBearing + " " + rBearing + " " + minY + ".svg" 
        Export(formatString) 
    endif
endloop;

