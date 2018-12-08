# TODO: Add flag to skip downloading hosts file
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

    set -l hosts_file_url 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
    set -l hosts blackhole.hosts
    set -l dnsmasq_hosts dnsmasq.blackhole.conf
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
        curl $hosts_file_url >$hosts
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
        set -l additional_hosts \
            facebook.com \
            hangouts.google.com \
            reddit.com \
            i.reddit.com
        for host in $additional_hosts
            echo "address=/$host/0.0.0.0" >>$dnsmasq_hosts
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
        scp $dnsmasq_hosts $router_ip:/config/user-data/$dnsmasq_hosts
        ssh $router_ip sudo cp /config/user-data/$dnsmasq_hosts /etc/dnsmasq.d
    end

    if set -q _flag_no_reload
        echo 'Skipping restart of dnsmasq on router'
    else
        echo 'Restarting dnsmasq on router...'
        ssh $router_ip sudo /etc/init.d/dnsmasq force-reload
    end
end
