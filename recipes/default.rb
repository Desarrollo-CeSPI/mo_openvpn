package 'openvpn'
package 'openvpn-auth-ldap'
package 'easy-rsa'
package 'mutt'
package 'zip'

template "#{node['mo_openvpn']['easy_rsa_install_dir']}/vars" do
  source 'easy-rsa-vars.erb'
  owner 'root'
  group 'root'
  variables({
    easy_rsa_dir: node['mo_openvpn']['easy_rsa_install_dir'],
    openvpn_install_dir: node['mo_openvpn']['install_dir'],
    key: node['mo_openvpn']['key']
  })
end

cookbook_file "#{node['mo_openvpn']['easy_rsa_install_dir']}/vars-revoke" do
  source 'vars-revoke'
  mode 0644
end

include_recipe 'mo_openvpn::build-server-certificates'

template '/etc/openvpn/auth' do
  source 'auth.erb'
  owner 'root'
  group 'root'
  variables({
     ldap_url: node['mo_openvpn']['ldap']['url'],
     ldap_basedn: node['mo_openvpn']['ldap']['basedn'],
     ldap_search_filter: node['mo_openvpn']['ldap']['search_filter']
  })
  notifies :restart, 'service[openvpn]'
end

template '/etc/openvpn/server.conf' do
  source 'server.conf.erb'
  owner 'root'
  group 'root'
  variables({
    server_network: node['mo_openvpn']['config']['server'],
    routes: node['mo_openvpn']['push_routes'],
    cert_filename: "#{node['fqdn']}.crt",
    key_filename: "#{node['fqdn']}.key"
  })
  notifies :restart, 'service[openvpn]'
end

template '/etc/openvpn/server-tcp.conf' do
  source 'server-tcp.conf.erb'
  owner 'root'
  group 'root'
  variables({
    server_network: node['mo_openvpn']['config']['server_tcp'],
    routes: node['mo_openvpn']['push_routes'],
    cert_filename: "#{node['fqdn']}.crt",
    key_filename: "#{node['fqdn']}.key"
  })
  notifies :restart, 'service[openvpn]'
end

cookbook_file '/etc/default/openvpn' do
  source 'openvpn'
  mode 0644
  notifies :restart, 'service[openvpn]'
end

service 'openvpn' do
  action :enable
  supports [:start, :stop, :restart, :reload]
end

sysctl_param 'net.ipv4.ip_forward' do
  value 1
end

node.set["simple_iptables"]["ipv4"]["tables"] = (Array(node["simple_iptables"]["ipv4"]["tables"]) + [ "nat" ]).uniq

nets = [node['mo_openvpn']['config']['server'],node['mo_openvpn']['config']['server_tcp']].map do |net|
  "--source #{net.gsub(' ', '/')}"
end

simple_iptables_rule "nat" do
  table "nat"
  chain "POSTROUTING"
  rule nets
  direction "POSTROUTING"
  jump "SNAT --to-source #{node['ipaddress']}"
end
