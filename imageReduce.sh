#!/bin/bash

# Funktion zum Anzeigen der Anleitung
show_usage() {
    echo "Usage: $0 input_dir output_dir max_size"
}

# Funktion zum Vergleichen von Dateigrößen
compare_files() {
    input_file_size=$(du -b "$1" | cut -f1)
    output_file_size=$(du -b "$2" | cut -f1)
    if [ "$input_file_size" -ge 1000000000 ]; then
        input_file_size=$(echo "scale=2; $input_file_size / 1000000000" | bc)
        input_file_size="$input_file_size GB"
        elif [ "$input_file_size" -ge 1000000 ]; then
        input_file_size=$(echo "scale=2; $input_file_size / 1000000" | bc)
        input_file_size="$input_file_size MB"
        elif [ "$input_file_size" -ge 1000 ]; then
        input_file_size=$(echo "scale=2; $input_file_size / 1000" | bc)
        input_file_size="$input_file_size KB"
    else
        input_file_size="$input_file_size Bytes"
    fi
    if [ "$output_file_size" -ge 1000000000 ]; then
        output_file_size=$(echo "scale=2; $output_file_size / 1000000000" | bc)
        output_file_size="$output_file_size GB"
        elif [ "$output_file_size" -ge 1000000 ]; then
        output_file_size=$(echo "scale=2; $output_file_size / 1000000" | bc)
        output_file_size="$output_file_size MB"
        elif [ "$output_file_size" -ge 1000 ]; then
        output_file_size=$(echo "scale=2; $output_file_size / 1000" | bc)
        output_file_size="$output_file_size KB"
    else
        output_file_size="$output_file_size Bytes"
    fi
    printf "| %-25s | %-20s | %-20s |\n" "$(basename "$1")" "$input_file_size" "$output_file_size"
}



# Überprüfen, ob mindestens zwei Argumente übergeben wurden
if [ "$#" -lt 2 ]; then
    show_usage
    exit 1
fi

# Erstes Argument ist der Eingabeordner
input_dir="$1"

# Zweites Argument ist der Ausgabeordner
output_dir="$2"

# Drittes Argument ist die maximal zulässige Dateigröße (in KB) für die verkleinerten Bilder
max_size="${3:-200}"

# Überprüfen, ob die Eingabe- und Ausgabeordner existieren
if [ ! -d "$input_dir" ]; then
    echo "Der Eingabeordner existiert nicht."
    exit 1
fi

if [ ! -d "$output_dir" ]; then
    echo "Der Ausgabeordner existiert nicht. Erstelle den Ordner..."
    mkdir "$output_dir"
fi

# Schleife durch alle Bilddateien im Eingabeordner
for file in "$input_dir"/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
    # Überprüfen, ob es sich um eine Bilddatei handelt
    if [ -f "$file" ]; then
        # Bilddateigröße ermitteln (in KB)
        size=$(du -k "$file" | cut -f1)
        
        # Wenn die Dateigröße größer als die zulässige Maximalgröße ist,
        # das Bild verkleinern und im Ausgabeordner speichern
        if [ "$size" -gt "$max_size" ]; then
            filename=$(basename -- "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"
            convert "$file" -resize 50% "$output_dir/$filename-small.$extension"
            echo "Das Bild $filename wurde verkleinert und im Ausgabeordner gespeichert."
            compare_files "$file" "$output_dir/$filename-small.$extension"
        else
            # Andernfalls das Originalbild im Ausgabeordner speichern
            cp "$file" "$output_dir/"
            echo "Das Bild $(basename -- "$file") wurde im Ausgabeordner gespeichert."
            compare_files "$file" "$output_dir/$(basename -- "$file")"
        fi
    fi
done

# Tabelle mit Vergleich von Dateigrößen anzeigen
printf "+---------------------------+----------------------+----------------------+\n"
printf "| Datei                     | Eingabedateigröße    | Ausgabedateigröße    |\n"
printf "+---------------------------+----------------------+----------------------+\n"

# Maximale Breite für die Spalte "Ausgabedateigröße" berechnen
max_output_size=$(du -h "$output_dir"/*.{jpg,JPG,jpeg,JPEG,png,PNG} 2>/dev/null | awk '{print $1}' | sort -hr | head -n 1)

for file in "$input_dir"/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
    if [ -f "$file" ]; then
        input_file_size=$(du -h "$file" | cut -f1)
        filename=$(basename -- "$file")
        output_file="$output_dir/${filename%.*}-small.${filename##*.}"
        if [ -f "$output_file" ]; then
            output_file_size=$(du -h "$output_file" | cut -f1)
            printf "| %-25s | %-20s | %-20s |\n" "$filename" "$input_file_size" "$output_file_size"
        else
            printf "| %-25s | %-20s | %-20s |\n" "$filename" "$input_file_size" "N/A"
        fi
    fi
done

# Trennlinie ausgeben
printf "+---------------------------+----------------------+----------------------+\n"
