#! /usr/bin/python

# Script originally created by JON HAYWARD: https://fattylewis.com/Graphing-pi-hole-stats/
# Adapted to work with InfluxDB by /u/tollsjo in December 2016
# Updated by Cludch December 2016

# To install and run the script as a service under SystemD. See: https://linuxconfig.org/how-to-automatically-execute-shell-script-at-startup-boot-on-systemd-linux

import requests
import time
from influxdb import InfluxDBClient

HOSTNAME = "pihole" # Pi-hole hostname to report in InfluxDB for each measurement
PIHOLE_API = "http://127.0.0.1/admin/api.php"
INFLUXDB_SERVER = "192.168.20.12" # IP or hostname to InfluxDB server
INFLUXDB_PORT = 8086 # Port on InfluxDB server
INFLUXDB_USERNAME = ""
INFLUXDB_PASSWORD = ""
INFLUXDB_DATABASE = "pihole"
DELAY = 10 # seconds

def send_msg(domains_blocked,dns_queries_today,ads_percentage_today,ads_blocked_today,unique_domains ,queries_forwarded ,queries_cached ,clients_ever_seen ,unique_clients ,dns_queries_all_types ,reply_NODATA ,reply_NXDOMAIN ,reply_IP ,privacy_level ,status):

        json_body = [
            {
                "measurement": "piholestats." + HOSTNAME.replace(".", "_"),
                "tags": {
                    "host": HOSTNAME
                },
                "fields": {
                    "domains_blocked": int(domains_blocked),
                    "dns_queries_today": int(dns_queries_today),
                    "ads_percentage_today": float(ads_percentage_today),
                    "ads_blocked_today": int(ads_blocked_today),
                    "unique_domains": int(unique_domains),
                    "queries_forwarded": int(queries_forwarded),
                    "queries_cached": int(queries_cached),
                    "clients_ever_seen": int(clients_ever_seen),
                    "unique_clients": int(unique_clients),
                    "dns_queries_all_types": int(dns_queries_all_types),
                    "reply_NODATA": int(reply_NODATA),
                    "reply_NXDOMAIN": int(reply_NXDOMAIN),
                    "reply_IP": int(reply_IP),
                    "privacy_level": int(privacy_level),
                    "status": str(status)
                }
            }
        ]

        client = InfluxDBClient(INFLUXDB_SERVER, INFLUXDB_PORT, INFLUXDB_USERNAME, INFLUXDB_PASSWORD, INFLUXDB_DATABASE) # InfluxDB host, InfluxDB port, Username, Password, database
        # client.create_database(INFLUXDB_DATABASE) # Uncomment to create the database (expected to exist prior to feeding it data)
        client.write_points(json_body)

if __name__ == '__main__':
        while True:
          api = requests.get(PIHOLE_API) # URI to pihole server api
          API_out = api.json()
          domains_blocked = API_out['domains_being_blocked']
          dns_queries_today = API_out['dns_queries_today']
          ads_percentage_today = str(API_out['ads_percentage_today'])
          ads_blocked_today = API_out['ads_blocked_today']
          unique_domains  = API_out['unique_domains']
          queries_forwarded  = API_out['queries_forwarded']
          queries_cached  = API_out['queries_cached']
          clients_ever_seen  = API_out['clients_ever_seen']
          unique_clients  = API_out['unique_clients']
          dns_queries_all_types  = API_out['dns_queries_all_types']
          reply_NODATA  = API_out['reply_NODATA']
          reply_NXDOMAIN  = API_out['reply_NXDOMAIN']
          reply_IP  = API_out['reply_IP']
          privacy_level  = API_out['privacy_level']
          status = API_out['status']

          send_msg(domains_blocked,dns_queries_today,ads_percentage_today,ads_blocked_today,unique_domains ,queries_forwarded ,queries_cached ,clients_ever_seen ,unique_clients ,dns_queries_all_types ,reply_NODATA ,reply_NXDOMAIN ,reply_IP ,privacy_level ,status)
          time.sleep(DELAY)
