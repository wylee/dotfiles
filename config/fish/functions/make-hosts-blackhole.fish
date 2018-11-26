# TODO: Add flag to skip downloading hosts file
# TODO: Add whitelist
function make-hosts-blackhole
    argparse --name='make-hosts-blackhole' \
        'D/no_download' \
        'e/echo' \
        'M/no_modify' \
        'U/no_upload' \
        'R/no_reload' \
        -- $argv

    set -l hosts blackhole.hosts
    set -l dnsmasq_hosts dnsmasq.blackhole.conf
    set -l router_ip 192.168.1.1

    if set -q _flag_no_download
        echo 'Skipping download of hosts file'
    else
        curl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts >$hosts
    end

    if set -q _flag_no_modify
        echo 'Skipping modification of downloaded hosts file'
    else
        sed -En 's!^0\.0\.0\.0 +([^ #]+).*$!address=/\1/0.0.0.0!p' $hosts >$dnsmasq_hosts
    end

    if set -q _flag_echo
        less $dnsmasq_hosts
    end

    if set -q _flag_no_upload
        echo 'Skipping upload of hosts file to router'
    else
        scp $dnsmasq_hosts $router_ip:/config/user-data/$dnsmasq_hosts
        ssh $router_ip sudo cp /config/user-data/$dnsmasq_hosts /etc/dnsmasq.d
    end

    if set -q _flag_no_reload
        echo 'Skipping restart of dnsmasq on router'
    else
        ssh $router_ip sudo /etc/init.d/dnsmasq force-reload
    end
end
