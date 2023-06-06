# frozen_string_literal: true

module Prenus
  module Output
    class Xlsout < Baseout
      #
      # Initialises the Xlsout class into an object
      #
      # @return [Object]
      #     Returns the Xlsout object
      #
      # @input
      #    events	 - the hash object with all the vulnerability events within it - @see Nessusin#import_nessus_files
      #    hosts   - the hash object with all the hosts within it - @see Nessusin#import_nessus_files
      #    options - the hash object with the configuration objections within it. These options include the output folder etc, and are used within many of the methods below
      #
      # @example
      #    object = Prenus::Output::Xmlout(events,hosts,options)
      #

      #
      # Run the Xmlout class - this will generate HTML file called .xls to the target folder
      #
      # @return
      #    Returns nothing
      #
      # @example
      #   object.run
      #
      def run
        # File.open(@options[:outputdir] + "/out.xls", 'w') do |f|

        @oFile.syswrite "<table border=1>\n"
        @oFile.syswrite "<tr><th>Nessus Plugin ID</th><th>Severity</th><th>Plugin Name</th><th>Synopsis</th><th>Description</th><th>Solution</th><th>Hosts</th></tr>\n"

        @events.each do |k, v|
          @oFile.syswrite "<tr><td>#{k}</td><td>#{v[:severity]}</td><td>#{v[:plugin_name]}</td><td>#{v[:synopsis]}</td><td>#{v[:description]}</td><td>#{v[:solution]}</td>"
          @oFile.syswrite '<td>'
          impacted_hosts = []
          v[:ports].each do |_k, v|
            v[:hosts].each do |h, _w|
              impacted_hosts << h
            end
          end
          impacted_hosts.uniq.each do |host|
            @oFile.syswrite "#{@hosts[host][:ip]}\n"
          end

          @oFile.syswrite "</td></tr>\n"
        end

        @oFile.syswrite "</table>\n"
        # end
      end
    end
  end end
