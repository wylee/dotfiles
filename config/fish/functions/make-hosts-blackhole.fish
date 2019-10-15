# TODO: Add whitelist
function make-hosts-blackhole
    set -l options \
        'D/no_download' \
        'C/no_create' \
        'A/no_add' \
        's/show' \
        'U/no_upload' \
        'R/no_reload' \
        'h/help'

    argparse --name='make-hosts-blackhole' $options -- $argv or return

    set -l directory (dirname (status -f))
    set -l additional_hosts_file "$directory/additional-blackhole-hosts"
    set -l hosts_file_url 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'
    set -l hosts blackhole.hosts
    set -l dnsmasq_hosts dnsmasq.blackhole.conf
    set -l router_dnsmasq_upload_path "/config/user-data/$dnsmasq_hosts"
    set -l router_dnsmasq_dir '/etc/dnsmasq.d'
    set -l router_ip 192.168.1.1

    if set -q _flag_help
        for option in $options
            echo $option
        end
        return
    end

    if set -q _flag_no_download
        echo 'Skipping download of hosts file'
    else
        echo "Downloading hosts file: $hosts_file_url..."
        curl -sS $hosts_file_url >$hosts
    end

    if set -q _flag_no_create
        echo 'Skipping creation of dnsmasq hosts file'
    else
        echo 'Creating dnsmasg file...'
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
        echo 'Uploading hosts file to router...'
        scp -q $dnsmasq_hosts $router_ip:$router_dnsmasq_upload_path
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
end
