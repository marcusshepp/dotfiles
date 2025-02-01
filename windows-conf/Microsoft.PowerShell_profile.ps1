function starteva {
    set-location ~/p/Legbone/Eva;
    $env:NODE_OPTIONS = "--max_old_space_size=8096";
    git st;
    npm start;
}

function eva {
    set-location ~/p/Legbone/Eva;
    git st;
}

function api {
    set-location ~/p/Legbone/EvaAPI;
    git st;
}

function scripts {
    set-location ~/p/useful;
}

function useful {
    set-location ~/p/useful;
}

function notes {
    set-location ~/p/notes;
    nvim .;
}

function lb {
    set-location ~/p/Legbone;
    git st;
}

function develop {
    set-location ~/p/Legbone;
    git checkout develop;
    git pull origin develop;
    git st;
}

function dotfiles {
    set-location ~/p/dotfiles;
    git st;
}

function done {
    git a .;
    git ci;
    git push origin HEAD;
}

function donee {
    param(
        [Parameter(Mandatory = $true)]
        [string]$c
    )
    git a .;
    git ci -m '$c';
    git ps;
}

function codegen {
    set-location ~/p/Legbone/Eva/codegen/scripts;
    ./generate.ps1;
    git st;
    starteva;
}

function pro {
    nvim "C:\Users\mshepherd\OneDrive - Michigan Senate\Documents\Powershell\Microsoft.Powershell_profile.ps1";
}

function nc {
    nvim ~\p\dotfiles\nvim\;
}

function lbr {
    git for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:iso8601) %(refname:short)';
}

function lsmigrations() {
    get-childitem ~\p\LegBone\EvaAPI\Migrations\ | `
    where-object { $_.Name -notlike '*Designer*' } | `
    where-object { $_.Name -notlike '*Snapshot*' } | `
    select-object -last 7 | `
    select-object -expandproperty Name
}

function c {
    Clear-Host;
}

function dd {
    & 'C:\Program Files\Docker\Docker\Docker Desktop.exe';
}

function serveexternal {
    ng serve --host=0.0.0.0 --disable-host-check;
}

function strapi {
    set-location ~/p/strapi/strapi;
    railway run npm run develop;
}

function glzr {
    set-location ~\.glzr;
    nvim .;
}

function touch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$filename
    )

    if (-not (Test-Path $filename)) {
        New-Item -ItemType file -Path $filename;
    } else {
        Write-Host "File already exists";
    }
}

function mkdir {
    param(
        [Parameter(Mandatory = $true)]
        [string]$dirname
    )

    if (-not (Test-Path $dirname)) {
        New-Item -ItemType directory -Path $dirname;
    } else {
        Write-Host "Directory already exists";
    }
}

function cp {
    param(
        [Parameter(Mandatory = $true)]
        [string]$source,
        [Parameter(Mandatory = $true)]
        [string]$destination
    )

    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $destination;
    } else {
        Write-Host "Source file does not exist";
    }
}

function mv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$source,
        [Parameter(Mandatory = $true)]
        [string]$destination
    )

    if (Test-Path $source) {
        Move-Item -Path $source -Destination $destination;
    } else {
        Write-Host "Source file does not exist";
    }
}

function ll {
    param (
            [string]$Path = "."
          )

        Get-ChildItem -Path $Path | ForEach-Object { $_.Name }
}

function wt {
    set-location ~\.;
    nvim .wezterm.lua;
}

function startdocker {
    $serviceName = "com.docker.service"

    # Check if the Docker service exists
    $dockerService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    if ($dockerService -eq $null) {
        Write-Host "Docker service is not installed on this system."
        return
    }

    # Check if the Docker service is already running
    if ($dockerService.Status -eq 'Running') {
        Write-Host "Docker service is already running."
    } else {
        Write-Host "Starting Docker service..."
        Start-Service -Name $serviceName

        # Wait for the service to start
        $dockerService.WaitForStatus('Running', '00:00:30')

        if ($dockerService.Status -eq 'Running') {
            Write-Host "Docker service started successfully."
        } else {
            Write-Host "Failed to start Docker service."
        }
    }
}

function startdocker2 {
        $dockerDaemonPath = "C:\Program Files\Docker\Docker\resources\dockerd.exe"

    if (Test-Path $dockerDaemonPath) {
        Write-Host "Starting Docker daemon directly..."
        Start-Process -FilePath $dockerDaemonPath -NoNewWindow -Verb RunAs
        Write-Host "Docker daemon started."
    } else {
        Write-Host "Docker daemon executable not found. Ensure Docker is installed."
    }
}


function startapi {
    set-location ~/p/Legbone/EvaAPI;
    $containerName = "evadb"
    $containerStatus = docker ps --filter "name=$containerName" `
        --filter "status=running" --format "{{.Names}}"

    if ($containerStatus -eq $null) {
        Write-Host "$containerName is not running. Starting the container..."
        docker start $containerName
    } else {
        Write-Host "$containerName is already running."
    }
    dotnet run;
}

function prox {
    proxima;
}

function kill4200 {
# Get the process ID (PID) of the process using port 4200
    $pid = (Get-NetTCPConnection -LocalPort 4200).OwningProcess

# Check if a process was found
            if ($pid) {
# Kill the process using its PID
            Stop-Process -Id $pid -Force 
                Write-Host "Process using port 4200 has been terminated."
        } else {
            Write-Host "No process found using port 4200."
        }
}

set-location ~\p\;


oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/nordtron.omp.json" | Invoke-Expression
