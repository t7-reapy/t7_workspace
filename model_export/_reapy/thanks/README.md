# What ?

This package will allow you to create easily customizable text as flickering and emissive textures in your maps.
Useful for any kind of crediting, like I did for my map, or just to put text as tags or anything alike in your environment

# Content

This package provides:
- 1 font, `Brushield.otf`
- 1 base texture, `model_export/_reapy/images/base_resource.jpg`
- 1 GIMP template, `model_export/_reapy/template_for_texture.xcf`
- 1 Prefilled GDT, `source_data/_reapy/thanks.gdt`

# How ?

Main entry point is the GIMP template of course ! To create your custom text, open `template_for_texture.xcf` with GIMP, and follow the instructions:
1. Change layer "initial text" to have the text you which to have in your new texture.
2. Right click it, then select "alpha to selection", it will draw a selection around your text.
3. From there, you need to click on layer "base resource image" and move it around if you wish.
4. When you happy with the positioning according to the current selection, click "Edit" tab, then "Copy"
5. Then "Edit" again, then "Paste in place"
6. Uncheck the little "eye" next to layers "base resource image" so you can see clearly the result
7. File > Export As > somewhere in your model_export folder as PNG file, I placed mine in `model_export/_reapy/textures`
8. Open APE, in the GDT named `thanks`, you can copy paste `thx_pastis` and `thx_pastis_c`, you will be asked a new name for the asset.
9. Change the color map (asset with name suffixed by `_c`) to target the new created file during point `7.`
10. Change the texture (asset with a blue round shape) to use the new color map in both Emissive Map & Color Map, instead of `thx_pastic_c`
11. In radiant, you should be able to use the new texture, and it should look like this:

![](./example_result.gif)
