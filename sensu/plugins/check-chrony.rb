#!/usr/bin/env /opt/sensu/embedded/bin/ruby
#
# Check NTP offset - yeah this is horrible.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'

class CheckChrony < Sensu::Plugin::Check::CLI

  option :warn,
    :short => '-w WARN',
    :proc => proc {|a| a.to_i },
    :default => 50

  option :crit,
    :short => '-c CRIT',
    :proc => proc {|a| a.to_i },
    :default => 100

  def run
    begin
      offset = `chronyc -a tracking | grep 'Last offset'`.split(' ')[3].strip.to_f
      offset *= 1000 # seconds -> milliseconds
    rescue
      unknown "chronyc tracking command Failed"
    end

    critical if offset >= config[:crit] or offset <= -config[:crit]
    warning if offset >= config[:warn] or offset <= -config[:warn]
    exit

  end
end
