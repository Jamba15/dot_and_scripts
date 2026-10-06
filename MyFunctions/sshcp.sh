sshcp() {
    # Declare associative array for hostname mappings
    declare -A hosts=(
        ["dante"]="giambagli@dante.physik.fu-berlin.de"
        ["sheldon"]="giambagli@sheldon.physik.fu-berlin.de"
        ["lise"]="bepjamba@blogin.hlrn.de"
        ["allegro"]="giambagli@allegro.imp.fu-berlin.de"
        ["juwels"]="giambagli1@juwels-booster.fz-juelich.de"
        ["jupiter"]="giambagli1@login.jupiter.fz-juelich.de"
    )
    
    local host1=""
    local path1=""
    local host2=""
    local path2=""
    local src=""
    local dst=""
    local uses_otp=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h)
                if [[ -z "$path1" ]]; then
                    host1="$2"
                    shift 2
                    path1="$1"
                    shift
                else
                    host2="$2"
                    shift 2
                    path2="$1"
                    shift
                fi
                ;;
            *)
                if [[ -z "$path1" ]]; then
                    path1="$1"
                else
                    path2="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Validate we have both paths
    if [[ -z "$path1" ]] || [[ -z "$path2" ]]; then
        echo "Usage: sshcp [-h hostname] path_1 [-h hostname] path_2"
        echo "Supported hostnames: dante, sheldon, lise, allegro, juwels, jupiter"
        return 1
    fi
    
    # Build source path
    if [[ -n "$host1" ]]; then
        if [[ -z "${hosts[$host1]}" ]]; then
            echo "Error: Unknown hostname '$host1'"
            echo "Supported hostnames: dante, sheldon, lise, allegro, juwels, jupiter"
            return 1
        fi
        src="${hosts[$host1]}:$path1"
        if [[ "$host1" == "juwels" || "$host1" == "jupiter" ]]; then
            uses_otp=true
        fi
    else
        src="$path1"
    fi
    
    # Build destination path
    if [[ -n "$host2" ]]; then
        if [[ -z "${hosts[$host2]}" ]]; then
            echo "Error: Unknown hostname '$host2'"
            echo "Supported hostnames: dante, sheldon, lise, allegro, juwels, jupiter"
            return 1
        fi
        dst="${hosts[$host2]}:$path2"
        if [[ "$host2" == "juwels" || "$host2" == "jupiter" ]]; then
            uses_otp=true
        fi
    else
        dst="$path2"
    fi
    
    # Execute scp with appropriate flags
    echo "Copying from: $src"
    echo "Copying to: $dst"
    
    if [[ "$uses_otp" == true ]]; then
        echo "Note: juwels/jupiter require OTP authentication. You will be prompted to enter your OTP code."
        # Use keyboard-interactive authentication for OTP
        scp -r -o PreferredAuthentications=keyboard-interactive,publickey "$src" "$dst"
    else
        scp -r "$src" "$dst"
    fi
}
