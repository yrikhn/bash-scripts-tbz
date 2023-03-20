#!/bin/bash

# Set the email address to send the report to
targetmail="peterlutzer2@gmail.com"

# Define the filename for the current week's expenses
filename="$(date +%Y-%U).txt"

# Check if the file for this week already exists, and if not, create it with a header line
if [ ! -f "$filename" ]; then
  echo "Day,Amount" > "$filename"
fi

# Define an array of day names
days=("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")

# Loop through the array and prompt the user to enter expenses for each day
for day in "${days[@]}"; do
  amount=""
  while [ -z "$amount" ]; do
    read -p "Enter expenses for $day: " amount
    if [ -n "$amount" ]; then
      echo "$(date +%F -d "last $day"),${amount//,/.}" >> "$filename"
    fi
  done
done

# Print a summary of the week's expenses
echo "Week $(date +%U) expenses:"
awk -F, 'NR>1 {sum+=$2} END {printf "Total: %.2f CHF\n", sum}' "$filename"
awk -F, 'NR>1 {print $1": "$2" CHF"}' "$filename" | column -t

# Check if there is a file for last week, and if so, compare the expenses
lastweek="$(date --date 'last week' +%Y-%U).txt"
if [ -f "$lastweek" ]; then
  echo "Comparison to last week:"
  lasttotal=$(awk -F, 'NR>1 {sum+=$2} END {printf "%.2f", sum}' "$lastweek")
  thistotal=$(awk -F, 'NR>1 {sum+=$2} END {printf "%.2f", sum}' "$filename")
  if (( $(echo "$thistotal > $lasttotal" | bc -l) )); then
    echo "This week spent more than last week"
  else
    echo "This week spent less than or equal to last week"
  fi
fi

# Send the report by email using ssmtp and the targetmail address
{
  echo "Subject: Weekly expenses report"
  echo "To: $targetmail"
  echo ""
  echo "Week $(date +%U) expenses:"
  awk -F, 'NR>1 {sum+=$2} END {printf "Total: %.2f CHF\n", sum}' "$filename"
  awk -F, 'NR>1 {print $1": "$2" CHF"}' "$filename" | column -t
} | ssmtp $targetmail
