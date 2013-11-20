#!/usr/bin/env python3
"""Update DNS A record for host on WebFaction.

This is intended for hosts that have a dynamic IP address (e.g., a home
sever). It assumes the host has only one associated A record.

An external service (currently ifconfig.me) is queried to get the host's
current IP address. This is compared against the IP address set by the
previous update. If these differ, the WebFaction XML-RPC API is used to
update the host's A record, and the new IP address is saved locally (to
~/.current-ip-address by default).

Note that all existing A records will be deleted before setting the new
IP address.

For typical usage, set up a cronjob like this (runs twice a day, at
midnight and noon)::

    0 0,12 * * * /usr/local/bin/python3 /path/to/update-dns.py -d host.example.com -u WEBFACTION_USERNAME -p WEBFACTION_PASSWORD >/dev/null

"""
import argparse
import os
from urllib.request import urlopen
from xmlrpc.client import ServerProxy


WEBFACTION_API_URL = 'https://api.webfaction.com/'
IP_ADDRESS_URL = 'http://ifconfig.me/ip'
CURRENT_IP_ADDRESS_FILE = os.path.expanduser('~/.current-ip-address')


def get_current_ip_address(current_ip_address_file):
    """Get current IP address (from last update)."""
    if os.path.exists(current_ip_address_file):
        with open(current_ip_address_file) as fp:
            current_ip_address = fp.read().strip()
    else:
        current_ip_address = None
    return current_ip_address


def get_new_ip_address():
    """Get (possibly) new IP address."""
    # TODO: Don't rely on external service
    with urlopen(IP_ADDRESS_URL) as fp:
        new_ip_address = fp.read().decode().strip()
    return new_ip_address


def ip_addresses_differ(current_ip_address, new_ip_address):
    return new_ip_address != current_ip_address


def update_ip_address(username, password, domain, new_ip_address):
    """Update A record on WebFaction."""
    server = ServerProxy(WEBFACTION_API_URL)
    session_id, account = server.login(username, password)
    server.delete_dns_override(session_id, domain)
    server.create_dns_override(session_id, domain, new_ip_address)


def write_new_ip_address(new_ip_address, file_name):
    """Save new IP address."""
    with open(file_name, 'w') as fp:
        fp.write(new_ip_address)
        fp.write('\n')


def main(argv=None):
    parser = argparse.ArgumentParser()

    parser.add_argument('-d', '--domain', required=True)
    parser.add_argument('-u', '--username', required=True)
    parser.add_argument('-p', '--password', required=True)
    parser.add_argument(
        '-c', '--current-ip-address-file', default=CURRENT_IP_ADDRESS_FILE)

    args = parser.parse_args(argv)
    domain = args.domain
    username = args.username
    password = args.password
    current_ip_address_file = args.current_ip_address_file

    current_ip_address = get_current_ip_address(current_ip_address_file)
    new_ip_address = get_new_ip_address()

    if ip_addresses_differ(current_ip_address, new_ip_address):
        print(
            'Updating IP address for {} ({} => {})...'
            .format(domain, current_ip_address, new_ip_address))
        update_ip_address(username, password, domain, new_ip_address)
        write_new_ip_address(new_ip_address, current_ip_address_file)
    else:
        print(
            'IP address already up to date for {} ({})'
            .format(domain, current_ip_address))


if __name__ == '__main__':
    main()

