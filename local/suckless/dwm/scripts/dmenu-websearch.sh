#!/usr/bin/env bash

sources_file="/usr/local/bin/dmenu-websearch-sources"

# dmenu theming
. /usr/local/bin/dmenu-theming

prompt="-p Search:"

se_data="$( 
    awk -F'"' '
    BEGIN {
        labels=""
    }
    {
        # Selector line
        gsub(/[[:space:]]/,"",$1)
        sel=$1
        
        # Description line
        dsc=$2
        
        # URL line
        gsub(/[[:space:]]/,"",$3)
        url=$3
        
        # URL array (selector is the key)
        surl[sel]=url
        
        # Descriptions array (selector is the key)
        sdsc[sel]=dsc
        
        if (labels != "") {
            labels=sprintf ("%s\n%s - %s", labels, sel, dsc)
        } else {
            labels=sprintf ("%s - %s", sel, dsc)
        }
    }
    END {
        for(k in surl) {
            print "declare -A " k
            print k "[url]=\"" surl[k] "\""
            print k "[dsc]=\"" sdsc[k] "\""
        }
        print "dmenu_labels=\"" labels "\""
    }
    ' "$sources_file"
)";

# Eval awk output as real variables...
eval "$se_data"

# Output label string to rofi...
search="$(dmenu $prompt $lines $colors $font <<< $dmenu_labels)"

if [[ ! -z "$search" ]]; then

    # Retrieve data...
    sel="$( awk '{ print tolower($1) }' <<< $search )"
    txt="$( cut -d" " -f2- <<< $search )"

    eval "sen_dsc=\"\${$sel[dsc]}\""
    eval "sen_url=\"\${$sel[url]}\""

    xdg-open "$sen_url$txt" &>/dev/null &

fi

exit 0
