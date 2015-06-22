package 'openvpn'
package 'openvpn-auth-ldap'

template '/etc/openvpn/auth' do
  source 'auth.erb'
  owner 'root'
  group 'root'
  variables({
     ldap_url: node['mo_openvpn']['ldap']['url'],
     ldap_basedn: node['mo_openvpn']['ldap']['basedn'],
     ldap_search_filter: node['mo_openvpn']['ldap']['search_filter']
  })
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
end
