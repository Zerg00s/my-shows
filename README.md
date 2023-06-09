# README.md

# My Shows

Welcome to the My Shows Trivia Project! This project consists of a PowerShell script and a GitHub Pages-hosted static site that hosts trivia about shows, seasons, and episodes. 

# 👉 [Click here to navigate to the site](https://zerg00s.github.io/my-shows/)

## Project Structure

- `./shows`: Directory containing folders for each show, each containing its own `index.html`.
- `./movies`: Similar to the shows directory, but for movies.
- `index.html`: The main homepage file for the static site.
- `show-template.html`: A template used to create the `index.html` file for each show.
- `season-template.html`: A template used to create the `index.html` file for each season.
- `episode-template.html`: A template used to create the `index.html` file for each episode.

## How it Works

1. The PowerShell script first cleans up any existing `index.html` files in the `shows` and `movies` directories.
2. It then generates an `index.html` file in each show directory, filled with hyperlinks to each season's `index.html` file.
3. The script performs a similar operation for each season within each show, generating an `index.html` file filled with hyperlinks to episode details.
4. If an `Episodes.csv` file is found in a season directory, the script reads it and generates links to trivia for each episode.
5. This script creates a nested structure of `index.html` files that allows users to navigate from the show level, to the season level, and finally to the episode level, each with its own trivia.

## How to Use

1. Clone this repository to your local machine.
2. Ensure that you have PowerShell installed and updated to its latest version.
3. Run the PowerShell script by typing `./script_name.ps1` in your terminal (replace `script_name.ps1` with the actual name of the script).
4. Once the script completes its execution, open `index.html` in a browser to navigate through the generated static site.

## Contributing

We appreciate contributions of any kind and value your time and effort. To contribute to this project, fork the project, create your feature branch from the `main` branch, commit your changes and push them to your fork, and open a pull request here.

## License

This project is licensed under the MIT License. See `LICENSE` for more information.

## Contact

If you have any questions, feel free to open an issue or reach out directly.

