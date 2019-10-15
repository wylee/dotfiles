# TODO: Add whitelist
function make-hosts-blackhole
    set -l options \
        'D/no_download' \
        'C/no_create' \
        'A/no_add' \
        's/show' \
        'U/no_upload' \
        'R/no_reload' \
        'k/keep_temp_files' \
        'h/help'

    argparse --name='make-hosts-blackhole' $options -- $argv or return

    set -l directory (dirname (status -f))
    set -l additional_hosts_file "$directory/additional-blackhole-hosts"
    set -l hosts_file_url 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'
    set -l temp_dir (mktemp -d /tmp/make-hosts-blackhole.XXX)
    set -l hosts (mktemp $temp_dir/blackhole.hosts.XXX)
    set -l dnsmasq_hosts_basename dnsmasq.blackhole.conf
    set -l dnsmasq_hosts (mktemp $temp_dir/$dnsmasq_hosts_basename.XXX)
    set -l router_dnsmasq_upload_path "/config/user-data/$dnsmasq_hosts_basename"
    set -l router_dnsmasq_dir '/etc/dnsmasq.d'
    set -l router_ip 192.168.1.1

    if set -q _flag_help
        echo 'Download list of hosts to block, convert to DNSmasq format, upload to router.'
        echo

        echo "Options:"
        for option in $options
            echo "    -"(string replace '/' ', --' (string replace '_' '-' $option))
        end

        rm -r $temp_dir
        return
    end

    if set -q _flag_no_download
        echo 'Skipping download of hosts file'
    else
        echo "Downloading hosts file $hosts_file_url to $hosts..."
        curl -sS $hosts_file_url >$hosts
    end

    if set -q _flag_no_create
        echo 'Skipping creation of dnsmasq hosts file'
    else
        echo "Creating dnsmasg file at $dnsmasq_hosts..."
        sed -En 's!^0\.0\.0\.0 +([^ #]+).*$!address=/\1/0.0.0.0!p' $hosts >$dnsmasq_hosts
    end

    if set -q _flag_no_add
        echo 'Skipping addition of additional hosts'
    else
        echo 'Adding additional hosts...'
        for host in (cat $additional_hosts_file)
            if not string match --quiet '#*' $host
                echo "address=/$host/0.0.0.0" >>$dnsmasq_hosts
            end
        end
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
        echo 'Skpping clearing of local DNS cache'
    else
        echo 'Restarting dnsmasq on router...'
        ssh -q $router_ip sudo systemctl restart dnsmasq
        echo "Clearing local DNS cache..."
        sudo killall -HUP mDNSResponder
    end

    if set -q _flag_keep_tempfiles
        echo "Deleting temp files:"
        for name in (rm -rv $temp_dir)
            echo "    $name"
        end
    else
        echo "Kept temp files:"
        for file in $temp_dir/*
            echo "    $temp_dir$file"
        end
        echo "    $temp_dir"
    end
end
