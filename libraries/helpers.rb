def mo_openvpn_index
  "#{node['mo_openvpn']['keys_dir']}/index.txt"
end

def mo_openvpn_user_id(user)
  "/CN=#{user}/"
end

def easy_rsa_dir
  node['mo_openvpn']['easy_rsa_install_dir']
end

def mo_openvpn_server_id
  node['fqdn']
end

def mo_openvpn_keys_dir
  node['mo_openvpn']['keys_dir']
end
