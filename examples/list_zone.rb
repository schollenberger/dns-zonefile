# First make sure you have installed the `dns-zonefile` gem.
#
# Run this script with `ruby list_zone.rb [zonefile]    # default example.com.zonefile
#
# Illustrates the lib usage by listing the parsing output and the load output for a given zonefile.
#
#

require 'dns/zonefile'

default_zonefile = File.dirname(__FILE__) + '/example.com.zonefile'

zonefile = ARGV[0] || default_zonefile

raise StandardError, "Zonefile #{zonefile} cannot be found" if ! File.exist?(zonefile)

zone_text = File.read(zonefile)

zone_raw =  DNS::Zonefile.parse(zone_text)

zone = DNS::Zonefile.load(zone_text, 'example.com')

out_line = "---------------------------------------------"
puts out_line
puts "Printing out the parse results:"
puts
puts "     Origin:     #{zone_raw.origin}"
puts "     SOA:        #{zone_raw.soa}"
puts "     RRs:"
zone_raw.rr.each do |row|
  puts "   - #{row.to_s}"
end

puts out_line
puts "Printing out the load results:"
puts
puts "SOA Origin:     #{zone.soa.origin}"
puts "SOA nameserver: #{zone.soa.nameserver}"
puts "RRs:"
max_dl = 40
zone.records.each do |rec|
  if rec.is_a?(DNS::Zonefile::MX)
    puts "   MX-Record: Host:   #{rec.host.ljust(max_dl)} Class: #{rec.klass} TTL: %6d - Prio: #{rec.priority} Domainname: #{rec.domainname}" % rec.ttl.to_i
  elsif rec.is_a?(DNS::Zonefile::AAAA)
    puts " AAAA-Record: Host:   #{rec.host.ljust(max_dl)} Class: #{rec.klass} TTL: %6d - Address: #{rec.address}" % rec.ttl.to_i
  elsif rec.is_a?(DNS::Zonefile::A)
    puts "    A-Record: Host:   #{rec.host.ljust(max_dl)} Class: #{rec.klass} TTL: %6d - Address: #{rec.address}" % rec.ttl.to_i
  elsif rec.is_a?(DNS::Zonefile::NS)
    puts "   NS-Record: Host:   #{rec.host.ljust(max_dl)} Class: #{rec.klass} TTL: %6d - Nameserver: #{rec.nameserver}" % rec.ttl.to_i
  elsif rec.is_a?(DNS::Zonefile::CNAME)
    puts "CNAME-Record: Host:   #{rec.host.ljust(max_dl)} Class: #{rec.klass} TTL: %6d - Domainname: #{rec.domainname}" % rec.ttl.to_i
  elsif rec.is_a?(DNS::Zonefile::SOA)
    puts "  SOA-Record: Origin: #{rec.origin.ljust(max_dl)} Class: #{rec.klass} TTL: %6d - Responsible party: #{rec.responsible_party}" % rec.ttl.to_i
  else
    puts "Skipped record class #{rec.class}"
  end
end
puts out_line
