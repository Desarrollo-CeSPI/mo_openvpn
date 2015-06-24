package 'openvpn'
package 'openvpn-auth-ldap'
package 'easy-rsa'

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

template "#{node['mo_openvpn']['easy_rsa_install_dir']}/vars" do
  source 'easy-rsa-vars.erb'
  owner 'root'
  group 'root'
  variables({
    easy_rsa_dir: node['mo_openvpn']['easy_rsa_install_dir'],
    openvpn_install_dir: node['mo_openvpn']['install_dir'],
    key: node['mo_openvpn']['key']
  })
  notifies :restart, 'service[openvpn]'
end

cookbook_file '/etc/default/openvpn' do
  source 'openvpn'
  mode 0644
  notifies :restart, 'service[openvpn]'
end

execute 'Create empty CRL file if not exist' do
  command "touch #{node['mo_openvpn']['keys_dir']}/crl.pem"
  not_if { ::File.exists?("#{node['mo_openvpn']['keys_dir']}/crl.pem")}
end

service 'openvpn' do
  action :enable
  supports [:start, :stop, :restart, :reload]
end
