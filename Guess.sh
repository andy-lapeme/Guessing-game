#!/bin/bash
if [ "$#" -gt 2 ]; then
echo "Usage: ./guess.sh <player> [easy|normal|hard]"
 exit 1
fi

# Get player name
player="$1"

# Validate player name
if [[ ! "$player" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Invalid player name!"
    exit 1
fi
difficulty="${2:-normal}"
difficulty=$(echo "$difficulty" | tr '[:upper:]' '[:lower:]')

case "$difficulty" in
    easy)
        min_number=1
        max_number=50
        ;;
    normal)
        min_number=1
        max_number=100
        ;;
    hard)
        min_number=1
        max_number=1000
        ;;
    *)
        echo "Invalid difficulty!"
        echo "Usage: ./guess.sh <player> [easy|normal|hard]"
        exit 1
        ;;
esac

# ==========================================
# GAME FILE
# ==========================================

GAMES_FILE="${GAMES_FILE:-games.txt}"
touch "$GAMES_FILE"

# ==========================================
# VALIDATE GAME RECORDS
# ==========================================

is_valid_game_line() {
    local line="$1"
    local player_name level start_time end_time
    local attempts duration
    local field_count

    field_count=$(awk -F'|' '{print NF}' <<< "$line")

    if [[ "$field_count" -ne 6 ]]; then
        return 1
    fi

    IFS='|' read -r player_name level start_time end_time attempts duration <<< "$line"

    if [[ -z "$player_name" || -z "$start_time" || -z "$end_time" ]]; then
        return 1
    fi

    case "$level" in
        easy|normal|hard)
            ;;
        *)
            return 1
            ;;
    esac

    if [[ ! "$attempts" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if [[ ! "$duration" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    return 0
}

# ==========================================
# COUNT INVALID GAME RECORDS
# ==========================================

count_invalid_games() {
    local line
    local invalid_count=0

    if [[ ! -f "$GAMES_FILE" ]]; then
        echo 0
        return
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ! is_valid_game_line "$line"; then
            ((invalid_count += 1))
        fi
    done < "$GAMES_FILE"

    echo "$invalid_count"
}

# ==========================================
# CHECK PERSONAL BEST
# ==========================================

check_personal_best() {
    local current_attempts="$1"
    local current_duration="$2"
    local line
    local game_player level start_time end_time
    local attempts duration
    local best_attempts=999999999
    local best_duration=999999999

    while IFS= read -r line || [[ -n "$line" ]]; do
        is_valid_game_line "$line" || continue

        IFS='|' read -r game_player level start_time end_time attempts duration <<< "$line"

        if [[ "$game_player" == "$player" && "$level" == "$difficulty" ]]; then
            if (( attempts < best_attempts )) ||
                { (( attempts == best_attempts )) && (( duration < best_duration )); }; then
                best_attempts="$attempts"
                best_duration="$duration"
            fi
        fi
    done < "$GAMES_FILE"

    if (( current_attempts < best_attempts )) ||
        { (( current_attempts == best_attempts )) && (( current_duration < best_duration )); }; then
        echo "New personal best! Congratulations!"
    fi
}

# ==========================================
# PLAY GAME
# ==========================================

play_game() {
    local secret_number
    local guess
    local attempts=0
    local start_time
    local end_time
    local start_seconds
    local end_seconds
    local duration

    secret_number=$(( RANDOM % (max_number - min_number + 1) + min_number ))

    start_seconds=$(date +%s)
    start_time=$(date '+%Y-%m-%d %H:%M:%S')

    echo ""
    echo "=== GUESS THE NUMBER ==="
    echo "Player: $player"
    echo "Difficulty: $difficulty ($min_number-$max_number)"
    echo "Type q to quit."

    while true; do
        read -r -p "Enter your guess: " guess || {
            echo ""
            echo "Game cancelled."
            return
        }

        if [[ "$guess" == "q" || "$guess" == "Q" ]]; then
            echo "You quit the game."
            return
        fi

        if [[ ! "$guess" =~ ^[0-9]+$ ]]; then
            echo "Please enter a valid number."
            continue
        fi

        if [[ "$guess" -lt "$min_number" || "$guess" -gt "$max_number" ]]; then
            echo "Please enter a number between $min_number and $max_number."
            continue
        fi

        ((attempts += 1))

        if [[ "$guess" -lt "$secret_number" ]]; then
            echo "Too low! Try again."
        elif [[ "$guess" -gt "$secret_number" ]]; then
            echo "Too high! Try again."
        else
            end_seconds=$(date +%s)
            end_time=$(date '+%Y-%m-%d %H:%M:%S')
            duration=$((end_seconds - start_seconds))

            echo ""
            echo "Congratulations, $player!"
            echo "You guessed the number in $attempts attempts."
            echo "Time taken: $duration seconds."

            check_personal_best "$attempts" "$duration"

            echo "$player|$difficulty|$start_time|$end_time|$attempts|$duration" >> "$GAMES_FILE"

            echo "Game saved successfully!"
            return
        fi
    done
}

# ==========================================
# SHOW GAME HISTORY
# ==========================================

show_history() {
    local line
    local player_name level start_time end_time
    local attempts duration
    local total_games=0
    local total_attempts=0
    local average_attempts=0

    echo ""
    echo "=== MY GAME HISTORY ==="

    printf "%-20s %-10s %-10s %-10s\n" \
        "DATE" "LEVEL" "ATTEMPTS" "DURATION"

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ! is_valid_game_line "$line"; then
            continue
        fi

        IFS='|' read -r player_name level start_time end_time attempts duration <<< "$line"

        if [[ "$player_name" == "$player" ]]; then
            printf "%-20s %-10s %-10s %-10s\n" \
                "$start_time" "$level" "$attempts" "$duration sec"

            ((total_games += 1))
            ((total_attempts += attempts))
        fi
    done < "$GAMES_FILE"

    if [[ "$total_games" -gt 0 ]]; then
        average_attempts=$((total_attempts / total_games))

        echo ""
        echo "=== SUMMARY ==="
        echo "Total games: $total_games"
        echo "Average attempts: $average_attempts"
    else
        echo "No games played yet."
    fi
}

# ==========================================
# SHOW LEADERBOARD
# ==========================================

show_leaderboard() {
    local line
    local game_player level start_time end_time
    local attempts duration
    local temp_file

    echo ""
    echo "=== LEADERBOARD - $difficulty ==="

    temp_file=$(mktemp) || {
        echo "Unable to create temporary file."
        return 1
    }

    while IFS= read -r line || [[ -n "$line" ]]; do
        is_valid_game_line "$line" || continue

        IFS='|' read -r game_player level start_time end_time attempts duration <<< "$line"

        if [[ "$level" == "$difficulty" ]]; then
            printf '%s|%s|%s|%s\n' \
                "$attempts" "$duration" "$game_player" "${end_time%% *}" >> "$temp_file"
        fi
    done < "$GAMES_FILE"

    if [[ ! -s "$temp_file" ]]; then
        echo "No $difficulty games played yet."
        rm -f "$temp_file"
        return
    fi

    sort -t '|' -k3,3 -k1,1n -k2,2n "$temp_file" |
        awk -F'|' '!seen[$3]++' |
        sort -t '|' -k1,1n -k2,2n |
        head -n 5 |
        awk -F'|' '
            BEGIN {
                printf "%-5s %-15s %-10s %-12s %-12s\n",
                "#", "PLAYER", "ATTEMPTS", "TIME", "DATE"
            }
            {
                printf "%-5d %-15s %-10s %-12s %-12s\n",
                NR, $3, $1, $2 " sec", $4
            }
        '

    rm -f "$temp_file"
}

# ==========================================
# DELETE MY HISTORY
# ==========================================

delete_my_history() {
    local answer
    local line
    local game_player level start_time end_time
    local attempts duration
    local deleted=0
    local temp_file

    echo ""
    read -r -p "Are you sure you want to delete your game history? (y/n): " answer

    case "$answer" in
        y|Y|yes|YES|Yes)
            ;;
        n|N|no|NO|No)
            echo "Nothing deleted."
            return
            ;;
        *)
            echo "Please answer y or n. Nothing deleted."
            return
            ;;
    esac

    if [[ ! -f "$GAMES_FILE" ]]; then
        echo "No game history found."
        return
    fi

    temp_file=$(mktemp "${GAMES_FILE}.tmp.XXXXXX") || {
        echo "Unable to create temporary file."
        return 1
    }

    while IFS= read -r line || [[ -n "$line" ]]; do
        if is_valid_game_line "$line"; then
            IFS='|' read -r game_player level start_time end_time attempts duration <<< "$line"

            if [[ "$game_player" == "$player" ]]; then
                ((deleted += 1))
                continue
            fi
        fi

        printf '%s\n' "$line" >> "$temp_file"
    done < "$GAMES_FILE"

    if mv "$temp_file" "$GAMES_FILE"; then
        echo "$deleted game(s) deleted successfully."
    else
        echo "Could not update game history."
        rm -f "$temp_file"
    fi
}

# ==========================================
# MAIN MENU
# ==========================================

while true; do

    invalid_count=$(count_invalid_games)

    echo ""
    echo "=== GUESS THE NUMBER ==="
    echo "Player: $player"
    echo "Difficulty: $difficulty"
    echo "Range: $min_number-$max_number"
    echo ""
    echo "1. Play Game"
    echo "2. View History"
    echo "3. Leaderboard"
    echo "4. Delete My History"
    echo "5. Quit"

    if [[ "$invalid_count" -gt 0 ]]; then
        echo "Warning: $invalid_count damaged line(s) ignored."
    fi

    read -r -p "Choose an option: " choice

    case "$choice" in
        1)
            play_game
            ;;
        2)
            show_history
            ;;
        3)
            show_leaderboard
            ;;
        4)
            delete_my_history
            ;;
        5)
            echo "Goodbye, $player!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please choose 1-5."
            ;;
    esac
done