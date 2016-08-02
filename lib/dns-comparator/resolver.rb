require 'resolv'

class Resolver
  TYPES = {
    A: Resolv::DNS::Resource::IN::A,
    AAAA: Resolv::DNS::Resource::IN::AAAA,
    SRV: Resolv::DNS::Resource::IN::SRV,
    MX: Resolv::DNS::Resource::IN::MX,
    NS: Resolv::DNS::Resource::IN::NS,
    TXT: Resolv::DNS::Resource::IN::TXT,
    PTR: Resolv::DNS::Resource::IN::PTR,
    CNAME: Resolv::DNS::Resource::IN::CNAME
  }

  def initialize(nameservers)
    @resolvers = nameservers.collect do |ns|
      Resolv::DNS.new(nameserver: ns)
    end
  end

  def resolve(record, type)
    t = TYPES[type.upcase.to_sym]

    results = @resolvers.map do |r|
      stringify(r.getresources(record, t), type)
    end

    ["#{record} #{type}", *results]
  end

  def stringify(resources, type)
    case type.upcase
    when 'A', 'AAAA'
      resources.map { |r| r.address.to_s }
    when 'CNAME', 'PTR'
      resources.map { |r| r.name.to_s }
    when 'MX'
      resources.map { |r| r.exchange.to_s }
    when 'SRV'
      resources.map { |r| "#{r.target}:#{r.port} #{r.priority} #{r.weight}" }
    when 'TXT'
      resources.map(&:strings)
    else
      resources.map(&:to_s)
    end
  end
end
