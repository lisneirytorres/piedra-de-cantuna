class_name UiFactory
extends RefCounted
## Crea controles de interfaz con el estilo común del juego (paneles, etiquetas, barras y botones).
##
## Centraliza colores y bordes para que toda la interfaz se vea coherente.

const PANEL_COLOR: Color = Color(0.07, 0.06, 0.1, 0.92)
const PANEL_BORDER_COLOR: Color = Color("c9a45c")
const TEXT_COLOR: Color = Color("efe6d2")
const ACCENT_COLOR: Color = Color("f2c35b")
const BAR_BACKGROUND_COLOR: Color = Color(0.0, 0.0, 0.0, 0.55)
const PANEL_MARGIN: int = 6
const BORDER_WIDTH: int = 1
const OUTLINE_SIZE: int = 3


## Estilo de panel oscuro con borde dorado.
static func make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = PANEL_BORDER_COLOR
	style.set_border_width_all(BORDER_WIDTH)
	style.set_content_margin_all(PANEL_MARGIN)
	return style


## Panel contenedor con el estilo del juego.
static func make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", make_panel_style())
	return panel


## Etiqueta con contorno, legible sobre cualquier fondo.
static func make_label(text: String, font_size: int, color: Color = TEXT_COLOR) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	label.add_theme_constant_override(&"outline_size", OUTLINE_SIZE)
	return label


## Barra de progreso sin texto, con el color de relleno indicado.
static func make_bar(fill_color: Color, size: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = size
	bar.max_value = 1.0
	bar.step = 0.0
	var background := StyleBoxFlat.new()
	background.bg_color = BAR_BACKGROUND_COLOR
	background.border_color = PANEL_BORDER_COLOR.darkened(0.4)
	background.set_border_width_all(BORDER_WIDTH)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	bar.add_theme_stylebox_override(&"background", background)
	bar.add_theme_stylebox_override(&"fill", fill)
	return bar


## Botón de menú con el estilo del juego.
static func make_button(text: String, font_size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override(&"font_size", font_size)
	button.add_theme_stylebox_override(&"normal", make_panel_style())
	var hover: StyleBoxFlat = make_panel_style()
	hover.bg_color = PANEL_COLOR.lightened(0.15)
	hover.border_color = ACCENT_COLOR
	button.add_theme_stylebox_override(&"hover", hover)
	button.add_theme_stylebox_override(&"focus", hover)
	button.add_theme_stylebox_override(&"pressed", hover)
	button.add_theme_color_override(&"font_focus_color", ACCENT_COLOR)
	button.add_theme_color_override(&"font_hover_color", ACCENT_COLOR)
	return button
