#!/usr/local/bin/fontforge

# Imports svg files (in "svgs to import/") into .ttf font file.
# Svg's must be named according to following convention:
#     IOS_WIKIGLYPH_W e950 100 100 100.svg
# The naming convention denotes the following:
#     NAME UNICODE LEFT_BEARING RIGHT_BEARING BASELINE_OFFSET.svg
# Run this script with command: 
#     fontforge -script import.py
# Fontforge python reference:
#    http://fontforge.org/python.html

# BASED ON: http://tex.stackexchange.com/questions/22487/create-a-symbol-font-from-svg-symbols



import fontforge
import glob

# Create font object.
font = fontforge.font()




# Adjust these settings as needed.
font.fontname = "WikiFontGlyphs-iOS"
font.fullname = "WikiFont-Glyphs iOS"
font.familyname = "WikiFont-Glyphs"
font.weight = "Book"
font.version    = "1.000"
font.encoding   = "Unicode"
font.copyright  = "(c)2014 Wikimedia, BSD License"
# This is the name used when generating the font file.
fileName = "WikiFont-Glyphs-iOS"



svgFolder = "./svgs to import/"
outputFolder = "./output/"

# Build array of glyph info dictionaries.
print "\nStarted importing glyphs into " + fileName
glyphDictionaries = []
for fullName in glob.glob(svgFolder + '*.svg'):
    fullName = fullName[len(svgFolder):]
    words = fullName.split()
    if (len(words) == 5):
        glyphDictionary = {}
        glyphDictionary["fullName"] = fullName
        glyphDictionary["unicodeChar"] = words[0]
        glyphDictionary["name"] = words[1]
        glyphDictionary["bearingLeft"] = words[2]
        glyphDictionary["bearingRight"] = words[3]
        glyphDictionary["baselineOffset"] = words[4][:-4]
        glyphDictionaries.append(glyphDictionary)


glyphDictionaries.sort(key=lambda x: x['name'])


# Add glyph for each dictionary entry to font object.
for glyphDictionary in glyphDictionaries:
        # Put new glyphs in the Private Use Area.
        glyph = font.createChar(int("0x{}".format(glyphDictionary["unicodeChar"]),0), glyphDictionary["name"])
        
        print "\tImporting \"" + glyphDictionary["fullName"] + "\""
        # Import svg data into the glyph.
        glyph.importOutlines(svgFolder + glyphDictionary["fullName"])
	
        # Make the glyph rest on the baseline + offset from file name.
        ymin = glyph.boundingBox()[1]
        glyph.transform([1, 0, 0, 1, 0, -ymin + int(glyphDictionary["baselineOffset"])])
        
        # Set glyph side bearings with values from file name.
        glyph.left_side_bearing = int(glyphDictionary["bearingLeft"])
        glyph.right_side_bearing = int(glyphDictionary["bearingRight"])



# Apply various fontforge settings.
font.round() # Needed to make simplify more reliable.
font.simplify()
font.removeOverlap()
font.round()
font.autoHint()
#font.canonicalContours()


# Generate actual font files.
#font.generate(fileName + ".pfb", flags=["tfm", "afm"]) # type1 with tfm/afm
#font.generate(fileName + ".otf") # opentype
font.generate(outputFolder + fileName + ".ttf") # truetype
print "Finished generating " + outputFolder + fileName + ".ttf"


# Build css file.
cssFileContentsHeader = """
@font-face {
    font-family: 'WikiFont-Glyphs';
    src: url('%s.eot'); /* IE9 Compat Modes */
    src: url('%s.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
         url('%s.woff') format('woff'), /* Modern Browsers */
         url('%s.ttf')  format('truetype'), /* Safari, Android, iOS */
         url('%s.svg#8088f7bbbdba5c9832b27edb3dfcdf09') format('svg'); /* Legacy iOS */
}
.wikiglyph {
    display: inline-block;
    height: 2.0em;
    width: 2.0em;
    text-align:center;
    font-family: 'WikiFont-Glyphs';
    -webkit-font-smoothing: antialiased;
    font-size: inherit;
    font-style: normal;
    font-weight: normal;
    line-height: 2.0em;
    overflow: visible;
}
.wikiglyph[dir='rtl'] {
  filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=0, mirror=1);
  -webkit-transform: scale(-1, 1);
  -moz-transform: scale(-1, 1);
  -ms-transform: scale(-1, 1);
  -o-transform: scale(-1, 1);
  transform: scale(-1, 1);
}
"""

cssFileContentsHeader = cssFileContentsHeader % (fileName, fileName, fileName, fileName, fileName)

file = open(outputFolder + "demo-glyphs.css", "w")
file.write(cssFileContentsHeader)
for glyphDictionary in glyphDictionaries:
        cssClassForGlyph = """
            .%s:before {
                content:"\%s";
            }
        """
	cssClassForGlyph = cssClassForGlyph % (glyphDictionary["name"], glyphDictionary["unicodeChar"])
        file.write(cssClassForGlyph)

file.close()




# Build html file.
htmlFileContentsHeader = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>%s minimal code</title>
    <link rel="stylesheet" href="demo-glyphs.css">
</head>
<style>
    body {
        margin: 2%% 15%% 2%% 15%%;
        color: #555;
        font-family: sans-serif;
        font-size: 2.0em;
    }

    hr { color: grey; }

    div {
        display: block;
        color: #777;
        border-bottom: 1px solid #eee;
        margin: 0.5em 0 0.5em 0;
    }
    div:hover {
        border-bottom-color: #cef;
    }
    span {
        color: #111;
    }
</style>
<body>
"""

htmlFileContentsHeader = htmlFileContentsHeader % (fileName)

file = open(outputFolder + "demo.html", "w")
file.write(htmlFileContentsHeader)

file.write("<h1>Glyphs</h1>")

# Grid of glyphs for top of html file.
counter = 0
for glyphDictionary in glyphDictionaries:
        divForGlyph = """
            <span class="wikiglyph %s"></span>
        """
	divForGlyph = divForGlyph % (glyphDictionary["name"])
        file.write(divForGlyph)
	counter += 1
	if (counter % 8) == 0:
            file.write("<br>")

file.write("<h1>Names</h1>")

# List of glyphs with names beneath grid.
for glyphDictionary in glyphDictionaries:
        divForGlyph = """
            <div><span class="wikiglyph %s"></span> %s</div>
        """
	divForGlyph = divForGlyph % (glyphDictionary["name"], glyphDictionary["name"])
        file.write(divForGlyph)

file.write("\n</body>\n</html>")
file.close()


print "Finished generating demo.html/css files\n"


