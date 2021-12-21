# TODO: Add whitelist
function make-hosts-blackhole
    set -l options \
        'D/no_download' \
        'A/no_add' \
        'C/no_create' \
        'U/no_upload' \
        'R/no_reload' \
        'F/no_flush' \
        'H/hosts=' \
        'l/local' \
        's/show' \
        'k/keep_temp_files' \
        'h/help'

    argparse --name='make-hosts-blackhole' $options -- $argv or return

    set -l directory (dirname (status -f))
    set -l additional_hosts_file "$directory/additional-blackhole-hosts"
    set -l hosts_file_url 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'
    set -l temp_dir (mktemp -d /tmp/make-hosts-blackhole.XXX)
    set -l hosts "$temp_dir/blackhole.hosts"
    set -l etc_hosts "$temp_dir/blackhole.etc_hosts"
    set -l etc_hosts_header '# Black hole hosts'
    set -l etc_hosts_footer '# End black hole hosts'
    set -l etc_hosts_backup_file '/etc/hosts.blackhole.bak'
    set -l dnsmasq_hosts_basename 'dnsmasq.blackhole.conf'
    set -l dnsmasq_hosts "$temp_dir/$dnsmasq_hosts_basename"
    set -l router_dnsmasq_upload_path "/config/user-data/$dnsmasq_hosts_basename"
    set -l router_dnsmasq_dir '/etc/dnsmasq.d'
    set -l router_ip '192.168.1.1'

    if set -q _flag_help
        echo 'Download list of hosts to block, convert to DNSmasq format, upload to router.'
        echo
        echo "Steps:"
        echo "  - Download hosts file from GitHub"
        echo "  - Add additional hosts from local file, if any"
        echo "  - Create dnsmasq hosts file"
        echo "  - Upload dnsmasq hosts file to router"
        echo "  - Restart dnsmasq service on router"
        echo "  - Flush DNS cache on local machine"
        echo
        echo "Options:"
        for option in $options
            echo "  -"(string replace '/' ', --' (string replace -a '_' '-' $option))
        end
        echo
        echo "-D/--no-download   Don't download hosts file"
        echo "-A/--no-add        Don't add additional hosts to downloaded hosts file"
        echo "-C/--no-create     Don't create dnsmasq hosts file"
        echo "-U/--no-upload     Don't copy dnsmasq hosts file to router"
        echo "-R/--no-reload     Don't reload dnsmasq on router"
        echo "-F/--no-flush      Don't flush DNS cache on local machine"
        echo "-H/--hosts <file>  Use specified hosts file rather than downloading"
        echo "-l/--local         Copy hosts to /etc/hosts on local machine rather than to the router"
        echo "-s/--show          Show contents of hosts file before copying to router or /etc/hosts"
        echo "-k/--keep          Keep temp files for inspection"
        echo "-h/--help          Show help"
        rm -r $temp_dir
        return
    end

    if set -q _flag_hosts
        echo "Using specified hosts file instead of downloading: $_flag_hosts"
        set hosts $_flag_hosts
    else if set -q _flag_no_download
        echo 'Skipping download of hosts file'
    else
        echo "Downloading hosts file $hosts_file_url to $hosts..."
        curl -sS $hosts_file_url >$hosts
    end

    if set -q _flag_no_add
        echo 'Skipping addition of additional hosts'
    else
        echo 'Adding additional hosts...'
        for host in (cat $additional_hosts_file)
            if not string match --quiet '#*' $host
                echo "0.0.0.0 $host" >>$hosts
            end
        end
    end

    if set -q _flag_local
        echo 'Copying hosts to /etc/hosts instead of uploading to router...'

        set _copy_lines yes

        while read line
            if test "$line" = "$etc_hosts_header"
                set -e _copy_lines
            else if test "$line" = "$etc_hosts_footer"
                set _copy_lines yes
            else if set -q _copy_lines
                echo $line >>$etc_hosts
            end
        end </etc/hosts

        set _last_line (string trim (tail -1 $etc_hosts))
        if not test "$_last_line" = ""
            echo >>$etc_hosts
        end

        echo "$etc_hosts_header" >>$etc_hosts
        sed -En 's!^0\.0\.0\.0 +([^ #]+).*$!0.0.0.0 \1!p' $hosts >>$etc_hosts
        echo "$etc_hosts_footer" >>$etc_hosts

        if set -q _flag_show
            echo "Showing contents of /etc/hosts file: $etc_hosts"
            less $etc_hosts
        end

        if set -q _flag_no_upload
            echo 'Skipping copying of hosts file to /etc/hosts'
        else
            echo "Backing up /etc/hosts to $etc_hosts_backup_file"
            sudo cp /etc/hosts $etc_hosts_backup_file
            echo "Copying hosts to /etc/hosts"
            sudo cp $etc_hosts /etc/hosts
        end
    else
        if set -q _flag_no_create
            echo 'Skipping creation of dnsmasq hosts file'
        else
            echo "Creating dnsmasg file at $dnsmasq_hosts..."
            sed -En 's!^0\.0\.0\.0 +([^ #]+).*$!address=/\1/0.0.0.0!p' $hosts >>$dnsmasq_hosts
        end

        if set -q _flag_show
            echo "Showing contents of dnsmasq file: $dnsmasq_hosts"
            less $dnsmasq_hosts
        end

        if set -q _flag_no_upload
            echo 'Skipping upload of hosts file to router'
        else
            echo "Uploading hosts file to router at $router_dnsmasq_upload_path..."
            scp -q $dnsmasq_hosts $router_ip:$router_dnsmasq_upload_path
            echo "Copying hosts file to $router_dnsmasq_dir..."
            ssh -q $router_ip sudo cp $router_dnsmasq_upload_path $router_dnsmasq_dir
        end

        if set -q _flag_no_reload
            echo 'Skipping restart of dnsmasq on router'
        else
            echo 'Restarting dnsmasq on router...'
            ssh -q $router_ip sudo systemctl restart dnsmasq
        end
    end

    if set -q _flag_no_flush
        echo 'Skipping clearing of local DNS cache'
    else
        echo "Clearing local DNS cache..."
        sudo killall -HUP mDNSResponder
    end

    if set -q _flag_keep_temp_files
        echo "Kept temp files:"
        echo "    $temp_dir"
        for file in $temp_dir/*
            echo "    $file"
        end
    else
        echo "Deleting temp files:"
        for name in (rm -rv $temp_dir)
            echo "    $name"
        end
    end
end
