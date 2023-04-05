#!/bin/bash

# Funktion zum Entfernen von Satzzeichen und Umwandlung in Kleinbuchstaben
sanitize_text() {
    local input=$1
    # Entferne Satzzeichen und wandele in Kleinbuchstaben um
    echo "$input" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]'
}

# Funktion zum Zählen der Wörter in einer Zeichenkette
count_words() {
    local input=$1
    local word_count=0
    # Zerlege die Zeichenkette in Wörter
    for word in $input; do
        ((word_count++))
    done
    echo $word_count
}

# Überprüfen, ob eine Datei als Parameter übergeben wurde
if [ $# -eq 0 ]; then
    echo "Es wurde keine Datei angegeben."
    exit 1
fi

# Überprüfen, ob die angegebene Datei existiert
if [ ! -f "$1" ]; then
    echo "Die angegebene Datei existiert nicht."
    exit 1
fi

# Dateiinhalt lesen und in eine Variable speichern
file_content=$(cat $1)

# Text bereinigen
clean_text=$(sanitize_text "$file_content")

# Text in Wörter aufteilen und in Array speichern
words=($clean_text)

# Anzahl der Wörter im Text
total_words=${#words[@]}

# Anzahl der verschiedenen Wörter im Text
unique_words=$(echo "${words[@]}" | tr ' ' '\n' | sort -u | wc -l)

echo "Textanalyse für Datei: $1"
echo "=============================================="
echo "Gesamtzahl der Wörter: $total_words"
echo "Anzahl der verschiedenen Wörter: $unique_words"
echo "=============================================="

# Häufigkeitsanalyse der Wörter im Text
declare -A word_count

for word in "${words[@]}"; do
    # Wenn das Wort bereits im Array existiert, erhöhe den Zähler
    if [ -n "${word_count[$word]}" ]; then
        ((word_count[$word]++))
    # Andernfalls füge das Wort dem Array hinzu
    else
        word_count[$word]=1
    fi
done

# Liste der am häufigsten verwendeten Wörter erstellen
echo "Die 10 am häufigsten verwendeten Wörter im Text:"
echo "=============================================="

counter=0
for word in $(echo "${!word_count[@]}" | tr ' ' '\n' | sort -nr -k2 | head -10); do
    ((counter++))
    count=${word_count[$word]}
    percentage=$(awk "BEGIN {printf \"%.2f\",${count}/${total_words}*100}")
    echo "$counter. $word ($count, $percentage%)"
done

