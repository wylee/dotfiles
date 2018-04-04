# TODO: Add flag to skip downloading hosts file
# TODO: Add whitelist
function make-hosts-blackhole
    set -l hosts blackhole.hosts
    set -l dnsmasq_hosts dnsmasq.blackhole.conf
    set -l router_ip 192.168.1.1

    curl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts >$hosts

    sed -En 's!^0\.0\.0\.0 (.+)$!address=/\1/0.0.0.0!p' $hosts >$dnsmasq_hosts

    scp $dnsmasq_hosts $router_ip:/config/user-data/$dnsmasq_hosts
    ssh $router_ip sudo cp /config/user-data/$dnsmasq_hosts /etc/dnsmasq.d
    ssh $router_ip sudo /etc/init.d/dnsmasq force-reload
end
