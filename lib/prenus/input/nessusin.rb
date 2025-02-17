# frozen_string_literal: true

module Prenus
  module Input
    class Nessusin
      #
      # This class method is used to convert a single (or collection) of .nessus (v2) files into 2 different hashes. events and hosts
      #
      # @return
      #   hosts  - a hash of hashes
      #            {<hostid> => {:ip => <ip>, :hostname => <hostname>, :os => <os>, :info => <number of informational findings>,
      #                          :low => <number of low findings>, :med => <number of medium findings>,
      #                          :high => <number of high findings>, :crit => <number of critical findings>,
      #                          :total => <total number of findings>, :total_excl_info => <total number of findings excluding informational findings>}}
      #   events - a hash of hashes
      #            {<nessus_id> => {:family => <vuln family>, :severity => <severity>, :plugin_name => <plugin name>,
      #                             :synopsis => <synopsis>, :description => <description>, :solution => <solution>, :see_also => <array of solutions>,
      #                             :cvss_base_score => <CVSS base score>, :cve => <CVE ID>, :cvss_vector => <CVSS vector>,
      #                             :ports => {<port string>, :hosts => {<hostid>, :result => <result>}}}
      #
      # @input
      #   options - the hash object with the configuration objections within it. These options include the output folder etc, and are used within many of the methods below
      #
      # @example
      #   hosts, events = Prenus::Input::Nessusin.import_nessus_files(options)
      #
      def self.import_nessus_files(options)
        hosts = {}  # initialise the output hosts hash
        events = {} # initialise the output events hash

        hostid = 0  # initialise the unique hostid

        # take the options[:input] parameter as a search parameter for input files, we don't check if these are .nessus files or anything
        # Dir.glob(options[:input]) do |nessus_file|
        options[:input].each do |nessus_file|
          Nessus::Parse.new(nessus_file) do |scan| # use the awesome ruby-nessus gem
            # in the scan file, iterate over each host
            scan.each_host do |host|
              ip = host.ip || '' # grap the IP
              # I've found sometimes if it doesn't have an IP it means its not scanned for whatever reasons .. like a printer
              next if ip == ''

              # I next here because I've found it easier to just ignore those which weren't scanned

              # Lets check if we want to skip an IP for .. whatever reason
              next if !options[:skip].nil? && options[:skip].include?(ip.to_s)

              hostname = host.hostname || '' # grab the hostname
              os = host.os || '' # grab the os
              os = os.gsub(/\n/, '/') # sometimes the OS is split over multiple lines - mange them together .. mange mange

              # Lets check if there's an override array in the config
              unless options[:override].nil?
                # Check for this IP address, as this is the primary key we use for overriding
                ovr = options[:override].detect { |x| x['ip'] == ip.to_s }
                unless ovr.nil?
                  os = ovr['os'] unless ovr['os'].nil? # Override the OS
                  hostname = ovr['hostname'] unless ovr['hostname'].nil? # Override the hostname
                end
              end

              info = host.informational_severity_count || 0 # grab the number of informational findings
              low = host.low_severity_count || 0 # grab the number of low findings
              med = host.medium_severity_count || 0 # grab the number of medium findings
              high = host.high_severity_count || 0 # grab the number of high findings
              crit = host.critical_severity_count || 0 # grab the number of critical findings

              targethostid = hostid # For the moment

              # Check to see if we already have the host (based on IP, Hostname and OS)
              if hosts.select do |_key, f|
                   (f[:os].to_s == os) && (f[:ip].to_s == ip) && (f[:hostname].to_s == hostname)
                 end.count.zero?
                # Okay, we don't have this host yet

                # add the host into the hosts hash
                hosts[hostid] =
                  { ip:, hostname:, os:, info:, low:, med:, high:, crit:,
                    total: info + low + med + high + crit, total_excl_info: low + med + high + crit }
                hostid += 1 # We only increase because we've added a new host
              else
                # We do have this host, lets grab the host id
                hosts.select do |_key, f|
                  f[:os].to_s == os and f[:ip].to_s == ip and f[:hostname] == hostname
                end.each { |k, _v| targethostid = k }

                # Lets now check who has the greatest number of findings, and then we'll use that one going forward
                if hosts[targethostid][:total].to_i < (info + low + med + high) # therefore the older, previously detected host had more - update the counters
                  hosts[targethostid][:info] = info
                  hosts[targethostid][:low] = low
                  hosts[targethostid][:med] = med
                  hosts[targethostid][:high] = high
                  hosts[targethostid][:crit] = crit
                  hosts[targethostid][:total] = info + low + med + high + crit
                  hosts[targethostid][:total_excl_info] = low + med + high + crit
                end
              end

              # Now lets iterate through each of the findings in this particular host
              host.each_event do |event|
                # If the events hash already has this event, lets just add this targethostid to it's hosts array within the ports hash
                if events.key?(event.id)

                  # Lets check the ports hash
                  if events[event.id][:ports].key?(event.port.to_s)

                    # We'll only add the hostid if the host's not already in the array
                    unless events[event.id][:ports][event.port.to_s][:hosts].include?(targethostid)
                      events[event.id][:ports][event.port.to_s][:hosts][targethostid] =
                        event.output
                    end

                  # Lets add this new port to this hash
                  else
                    events[event.id][:ports][event.port.to_s] = { hosts: { targethostid => event.output } }
                  end

                # okay, this event doesn't exist, lets add it to the events hash
                else
                  events[event.id] = {
                    # :hosts => [hostid],									#start the hosts array
                    family: event.family || '',	# vuln family
                    severity: event.severity || '',	# severity
                    plugin_name: event.plugin_name || '',	# plugin name
                    synopsis: event.synopsis || '',	# synopsis
                    description: event.description || '',	# description
                    solution: event.solution || '',					# solution
                    see_also: event.see_also || '',					# see also array
                    cvss_base_score: event.cvss_base_score || '',	# CVSS base score
                    cve: event.cve || '',	# CVE
                    cvss_vector: event.cvss_vector || '',	# CVSS vector
                    # :port => event.port.to_s || ""						#port
                    ports: {}
                  }
                  events[event.id][:ports][event.port.to_s] = { hosts: { targethostid => event.output } }
                end
              end
            end
          end
        end

        # sort the events by severity crit, high, med, low, info
        events = events.sort_by { |_k, v| v[:severity] }.reverse

        # return the hosts and the events hashes
        [hosts, events]
      end
    end
  end end
