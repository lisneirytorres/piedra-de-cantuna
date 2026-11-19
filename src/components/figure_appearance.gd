@tool
class_name FigureAppearance
extends Resource
## Aspecto de un personaje dibujado por [PixelFigure]: colores y tocado.
##
## Cada personaje tiene su [code].tres[/code] en [code]src/data/appearances/[/code].

## Prenda o rasgo que lleva en la cabeza.
enum Headwear { NONE, HOOD, HAT, HORNS, SHAWL, CAP }

@export var skin_color: Color = Color("c08a5e")
@export var hair_color: Color = Color("1f1714")
@export var body_color: Color = Color("3f6d8c")
@export var legs_color: Color = Color("3a2e28")
@export var headwear: Headwear = Headwear.NONE
@export var headwear_color: Color = Color("6b4a2f")
## Color de los ojos (útil para que brillen los diablos).
@export var eye_color: Color = Color("1a1210")
