require 'spec_helper'

describe Lita::Handlers::Dig, lita_handler: true do
  let(:resolve) do
    client = double
    allow(client).to receive(:nameservers=) { '' }
    expect(client).to receive(:query) { 'Generic A response example.com' }
    client
  end

  let(:resolve_mx) do
    client = double
    allow(client).to receive(:nameservers=) { '' }
    expect(client).to receive(:query) { 'Generic MX response example.com' }
    client
  end

  let(:resolve_unknown) do
    client = double
    allow(client).to receive(:nameservers=) { '' }
    expect(client).to receive(:query) { 'Unknown domain example.com' }
    client
  end

  let(:resolve_noresponse) do
    client = double
    allow(client).to receive(:nameservers=) { '' }
    expect(client).to receive(:query).and_throw(:NoResponseError)
    client
  end

  it { routes_command('dig example.com').to(:resolve) }
  it { routes_command('dig example.com MX').to(:resolve_type) }
  it { routes_command('dig @8.8.8.8 example.com').to(:resolve_svr) }
  it { routes_command('dig @8.8.8.8 example.com MX').to(:resolve_svr_type) }

  describe '#resolve' do
    it 'shows a record if the domain exists' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve }
      send_command('dig example.com')
      expect(replies.last).to eq('Generic A response example.com')
    end

    it 'shows a warning if the domain does not exist' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_unknown }
      send_command('dig example.com')
      expect(replies.last).to eq('Unknown domain example.com')
    end

    it 'shows an error if the request fails' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_noresponse }
      send_command('dig example.com')
      expect(replies.last).to eq('Unable to resolve example.com')
    end
  end

  describe '#resolve_type' do
    it 'resolves a uppercase record with a particular type' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_mx }
      send_command('dig example.com MX')
      expect(replies.last).to eq('Generic MX response example.com')
    end

    it 'resolves a lowercase record with a particular type' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_mx }
      send_command('dig example.com mx')
      expect(replies.last).to eq('Generic MX response example.com')
    end

    %w(a ns md cname soa mb mg mr null wks ptr hinfo minfo mx txt rp afsdb
       x25 isdn rt nsap nsapptr sig key px gpos aaaa loc nxt eid nimloc srv
       atma naptr kx cert dname opt ds sshfp rrsig nsec dnskey uinfo uid gid
       unspec tkey tsig ixfr axfr mailb maila any).each do |type|
      it 'resolves a record with a particular type' do
        expect(Net::DNS::Resolver).to receive(:new) { resolve }
        send_command("dig example.com #{type}")
        expect(replies.last).to eq('Generic A response example.com')
      end
    end

    it 'shows a warning if the domain does not exist' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_unknown }
      send_command('dig example.com MX')
      expect(replies.last).to eq('Unknown domain example.com')
    end

    it 'shows a warning if the type does not exist' do
      send_command('dig example.com omg')
      expect(replies.last).to eq('Unknown record type')
    end

    it 'shows an error if the request fails' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_noresponse }
      send_command('dig example.com MX')
      expect(replies.last).to eq('Unable to resolve example.com')
    end
  end

  describe '#resolve_svr' do
    it 'shows a record if the domain exists' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve }
      send_command('dig @8.8.8.8 example.com')
      expect(replies.last).to eq('Generic A response example.com')
    end

    it 'shows a warning if the domain does not exist' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_unknown }
      send_command('dig @8.8.8.8 example.com')
      expect(replies.last).to eq('Unknown domain example.com')
    end

    it 'shows an error if the request fails' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_noresponse }
      send_command('dig @8.8.8.8 example.com')
      expect(replies.last).to eq('Unable to resolve example.com')
    end
  end

  describe '#resolve_type' do
    it 'resolves a uppercase record with a particular type' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_mx }
      send_command('dig @8.8.8.8 example.com MX')
      expect(replies.last).to eq('Generic MX response example.com')
    end

    it 'resolves a lowercase record with a particular type' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_mx }
      send_command('dig @8.8.8.8 example.com mx')
      expect(replies.last).to eq('Generic MX response example.com')
    end

    it 'shows a warning if the domain does not exist' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_unknown }
      send_command('dig @8.8.8.8 example.com MX')
      expect(replies.last).to eq('Unknown domain example.com')
    end

    it 'shows an error if the request fails' do
      expect(Net::DNS::Resolver).to receive(:new) { resolve_noresponse }
      send_command('dig @8.8.8.8 example.com MX')
      expect(replies.last).to eq('Unable to resolve example.com')
    end
  end
end
