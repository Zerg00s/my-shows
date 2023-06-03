. .\Clean-Subtitles.ps1

# Get all files from the Shows folder
$files = Get-ChildItem -Path $ShowsPath -Recurse -File

# If the .srt file does not have a corresponding .txt file, create one
foreach ($file in $files) {
    $srtFilePath = $file.FullName
    $txtFilePath = $srtFilePath -replace '\.srt$', '.txt'
    # Skip .html and .csv files
    if ($srtFilePath -match '\.html$|\.csv$') {
        continue
    }

    if (-not (Test-Path -Path $txtFilePath)) {
        Write-Host "Creating file: $txtFilePath"
        Clean-Subtitles -FilePath $srtFilePath -OutputFilePath $txtFilePath
    }
}

# ================================================================================================== #
# Remove all index.html except for the one in the root folder
# ================================================================================================== #

$IndexFiles = Get-ChildItem -Path .\shows -File -Filter 'index.html' -Recurse
$IndexFiles | Remove-Item -Force
$IndexFiles = Get-ChildItem -Path .\movies -File -Filter 'index.html' -Recurse
$IndexFiles | Remove-Item -Force


# ================================================================================================== #
# Insert all shows to the index.html file
# ================================================================================================== #
# Get list of folders in Shows directory
$shows = Get-ChildItem -Path '.\Shows\' -Directory

# Initialize list
$ul = "<ul>"

# Iterate over shows and add list items with hyperlinks
foreach ($show in $shows) {
    $ul += "<li><a href='.\Shows\$($show.Name)\index.html'>$($show.Name)</a></li>"
}

# Close list
$ul += "</ul>"

# Load the index.html content
$indexContent = Get-Content -Path .\index.html -Raw

# Replace the placeholder with the list
$newContent = $indexContent -replace '(?s)(<div id="shows">).*?(</div>)', "`$1$ul`$2"

# Write the updated content back to the index.html file
Set-Content -Path .\index.html -Value $newContent

# ================================================================================================== #
# For each show, create index.html file if does not exist
# ================================================================================================== #
# Get the content of the show-template.html file
$ShowTemplateContent = Get-Content -Path .\show-template.html -Raw
$SeasonTemplateContent = Get-Content -Path .\season-template.html -Raw
$EpisodeTemplateContent = Get-Content -Path .\episode-template.html -Raw

# Get list of folders in Shows directory
$shows = Get-ChildItem -Path '.\Shows\' -Directory

# Iterate over each show (subfolder)
foreach ($show in $shows) {
    # Determine the path to the index.html file for this show
    $indexPath = Join-Path -Path $show.FullName -ChildPath "index.html"
  
    # Replace placeholder in the template with the actual show name
    $showContent = $ShowTemplateContent -replace '\{\{show-name\}\}', $show.Name

    # Check if the index.html file already exists
    if (-not (Test-Path -Path $indexPath)) {
        # If it does not exist, create it with the content of the template
        Set-Content -Path $indexPath -Value $showContent
    }
    
    # ================================================================================================== #
    # Insert all seasons to the index.html file
    # ================================================================================================== #
    # Get list of folders in Shows directory
    $seasons = Get-ChildItem -Path $show.FullName -Directory

    # Initialize list
    $ul = "<ul>"

    # Iterate over seasons and add list items with hyperlinks
    foreach ($season in $seasons) {
        $ul += "<li><a href='.\$($season.Name)\index.html'>$($season.Name)</a></li>"
    }

    # Close list
    $ul += "</ul>"

    # Load the index.html content
    $showIndexPath  = $show.FullName + "\index.html"
    $indexContent = Get-Content -Path $showIndexPath -Raw

    # Replace the placeholder with the list
    $newContent = $indexContent -replace '(?s)(<div id="seasons" class="mt-4">).*?(</div>)', "`$1$ul`$2"

    # Write the updated content back to the index.html file
    Set-Content -Path $showIndexPath -Value $newContent

    # iterate over seasons in the show (subfolder) 
    $seasons = Get-ChildItem -Path $show.FullName -Directory
    foreach ($season in $seasons) {
        # Determine the path to the index.html file for this season
        $seasonIndexPath = Join-Path -Path $season.FullName -ChildPath "index.html"
        # Check if the index.html file already exists
        if (-not (Test-Path -Path $seasonIndexPath)) {
            # If it does not exist, create it with the content of the template
            $seasonsContent = $SeasonTemplateContent -replace '\{\{season-name\}\}', $season.Name
            Set-Content -Path $seasonIndexPath -Value $seasonsContent

            # Chech if Episodes.csv file exists
            $EpisodesFilePath = Join-Path -Path $season.FullName -ChildPath "Episodes.csv"
            # check if $episodesFilePath exists

            if (Test-Path $episodesFilePath) {
                Write-Host "The file exists."



            # Get the content of the Episodes.csv file
            $csvEpisodes = Import-Csv -Path $EpisodesFilePath

            # Initialize an empty array to store the new objects
            $episodes = @()

            # Get a list of all .txt files in the current season folder
            $txtFiles = Get-ChildItem -Path $season.FullName -File -Filter '*.txt'

            foreach ($file in $txtFiles) {
                # Extract episode number from file name
                # Extract episode number from file name and remove leading zeroes
                $episodeNumber = [regex]::Match($file.Name, "(?<=E)\d+").Value.TrimStart('0')

                
                # Get the corresponding row from the CSV file
                $csvEpisode = $csvEpisodes | Where-Object { $_.Episode -eq $episodeNumber }

                # Create a custom object with the episode metadata and add it to the array
                $episode = New-Object PSObject -Property @{
                    FileName = $file.Name
                    EpisodeNumber = $episodeNumber
                    EpisodeTitle = $csvEpisode.Title
                    AirDate = $csvEpisode.'Air Date'
                    # Add other metadata from the CSV file as desired
                }

                $episodes += $episode
            }



            # ================================================================================================== #
            # Create UL list of episodes
            $html = "<ul>"

            foreach ($episode in $episodes) {
                # Create an HTML list item for each episode
                $html += "<li> $($episode.EpisodeNumber) - <a href=`"$($episode.FileName)`">$($episode.EpisodeTitle) - $($episode.AirDate)</a> - <a style='margin:20px' class='btn btn-secondary' href='trivia.html?Markdown=$($episode.FileName).md&Episode=$($episode.EpisodeNumber) - $($episode.EpisodeTitle)'>View Trivia</a></li>"
            }

            # Close the unordered list
            $html += "</ul>"
            # ================================================================================================== #


            # Load the existing HTML file into a string
            $htmlContent = Get-Content -Path $seasonIndexPath -Raw

            # Placeholder for the episodes <div>
            $placeholder = '<div id="episodes" class="mt-4"></div>'

            # Construct the new HTML block with the episode list
            $newContent = "<div id=`"episodes`" class=`"mt-4`"></div>$html</div>"

            # Replace the placeholder with the new content
            $newHtmlContent = $htmlContent -replace $placeholder, $newContent

            # Write the new HTML content back to the file
            Set-Content -Path $seasonIndexPath -Value $newHtmlContent

            } else {
                Write-Host "The file does not exist."
            }
           
        }

    }
}
