local tu = require "texutil"

function data()
return {
	detailTex = tu.makeTextureMipmapRepeat("streets/old_small_paving.tga", true, true),
	detailNrmlTex = tu.makeTextureMipmapRepeat("streets/old_small_paving_nrml.tga", true, true, true),
	detailSize = { 12.0, 12.0 },
	colorTex = tu.makeTextureMipmapRepeat("streets/old_overlay_01.tga", false),
	colorSize = 32.0
}
end
