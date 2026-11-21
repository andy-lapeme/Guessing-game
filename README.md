# Guess the Number — Weekend Edition

## Project Overview

**Guess the Number — Weekend Edition** is an interactive command-line game built with Bash that challenges players to guess a randomly generated secret number.

The game offers three difficulty levels — Easy, Normal, and Hard — providing different number ranges and levels of challenge. It also tracks game history, records player performance, and displays a leaderboard to encourage players to improve their scores.

This project demonstrates Bash scripting, shell programming, input validation, file handling, and data management.

## Project Purpose

This project solves the challenge of creating an engaging command-line game by providing an interactive number-guessing experience for players.

It was developed as a learning project to practice Bash programming concepts and strengthen problem-solving skills.

## Features

- **Player Name Validation:** Ensures that players enter a valid name.
- **Difficulty Levels:** Choose between:
  - Easy: Guess a number between 1 and 50.
  - Normal: Guess a number between 1 and 100.
  - Hard: Guess a number between 1 and 1000.
- **Interactive Gameplay:** Receive hints indicating whether the secret number is higher or lower than your guess.
- **Input Validation:** Handles invalid inputs and prevents incorrect entries.
- **Quit Option:** Allows players to leave a game using `q`.
- **Game History:** Displays previously completed games and performance summaries.
- **Personal Best:** Tracks a player's best performance for each difficulty level.
- **Leaderboard:** Displays the top five players for the selected difficulty.
- **Data Persistence:** Saves completed games in a text file.
- **Corrupted Data Handling:** Detects and ignores invalid game records.
- **Delete History:** Allows players to delete their own game records without deleting other players' records.

## Technologies Used

- **Bash:** Main programming language.
- **Shell Scripting:** Game logic and automation.
- **Git:** Version control.
- **GitHub:** Source code hosting and collaboration.
- **VS Code:** Development environment.

## Getting Started

### Prerequisites

Before running the project, make sure you have:

- A computer running macOS or Linux.
- A Bash-compatible terminal.
- Git installed.
- Visual Studio Code (optional, for editing the code).

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/andy-lapeme/Guessing-game.git
   ```

2. Enter the project directory:

   ```bash
   cd Guessing-game
   ```

3. Make the script executable:

   ```bash
   chmod +x guess.sh
   ```

4. Run the game:

   ```bash
   ./guess.sh
   ```

### Usage

You can start the game by providing a player name:

```bash
./guess.sh ama
```

You can also specify a difficulty level:

```bash
./guess.sh ama easy
./guess.sh ama normal
./guess.sh ama hard
```

If no difficulty is specified, the game uses **Normal** by default.

Difficulty names are case-insensitive.

## Project Structure

```text
Guessing-game/
│
├── guess.sh       # Main Bash game script
├── games.txt      # Saved game records (created when needed)
├── README.md      # Project documentation
└── .gitignore     # Files excluded from Git (if configured)
```

## Game Data Format

Completed games are stored in a text file using the following format:

```text
player|level|start_time|end_time|attempts|duration_seconds
```

Example:

```text
ama|normal|2026-10-24 14:03:11|2026-10-24 14:04:02|7|51
```

Each record contains:

- Player name
- Difficulty level
- Game start time
- Game end time
- Number of attempts
- Game duration in seconds

Invalid or corrupted records are ignored when displaying statistics and rankings.

## Leaderboard

The leaderboard ranks the five best players for the selected difficulty.

Ranking is based on:

1. The lowest number of attempts.
2. The shortest game duration when attempts are equal.

Only each player's best game is displayed.

## 🎓 Learning Objectives

This project was developed to practice:

- Bash variables and command-line arguments.
- Conditional statements (`if`, `case`).
- Loops (`while`, `for`).
- Functions.
- Input validation and regular expressions.
- Random number generation.
- File reading and writing.
- Data filtering and sorting.
- Temporary files.
- Git branching, commits, and pull requests.

## Future Improvements

Possible improvements include:

- Adding more difficulty levels.
- Introducing multiplayer gameplay.
- Adding colorful terminal output.
- Improving the leaderboard with additional statistics.
- Creating a graphical user interface.

## Author

**Andy Lapeme**

GitHub: [andy-lapeme](https://github.com/andy-lapeme)

## License

This project was created for educational purposes. Contributions and improvements are welcome.