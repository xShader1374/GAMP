shader_type canvas_item;
render_mode unshaded;

// Variabile uniforme per l'altezza delle colonne
uniform float heights[1024];
uniform float columnsOpacity : hint_range(0.0, 1.0, 0.001) = 1.0;
uniform float BGOpacity : hint_range(0.0, 1.0, 0.001) = 1.0;
uniform vec3 color;
uniform vec3 BGColor;
uniform int num_columns = 16;

void fragment() {
    // Calcola l'indice della colonna basato sulla coordinata x del pixel
    int index = int(UV.x * float(num_columns));

    // Controlla se l'indice è valido
    if (index < 0 || index >= num_columns) {
        COLOR = vec4(BGColor, BGOpacity);
    }

    // Ottieni l'altezza della colonna
    float p = UV.x * float(num_columns);
    float f = heights[0];
    for (int i = 1; i < num_columns; i++) {
        f = mix( f, heights[i], clamp( p - float(i), 0.0, 1.0 ) );
    }

    // Se la coordinata y del pixel è inferiore all'altezza della colonna, colora il pixel
    if (UV.y < f) {
        COLOR = vec4(color, columnsOpacity);
    } else {
        COLOR = vec4(BGColor, BGOpacity);
    }
}
