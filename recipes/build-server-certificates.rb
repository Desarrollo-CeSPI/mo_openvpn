easy_rsa_dir = node['mo_openvpn']['easy_rsa_install_dir']

execute 'Build CA Key' do
  command ". #{easy_rsa_dir}/vars && #{easy_rsa_dir}/clean-all && #{easy_rsa_dir}/pkitool --initca"
  not_if { ::File.exists?("#{node['mo_openvpn']['keys_dir']}/ca.crt")}
end

execute 'Build Server Key' do
  command ". #{easy_rsa_dir}/vars && #{easy_rsa_dir}/pkitool --server #{node['fqdn']}"
  not_if { ::File.exists?("#{node['mo_openvpn']['keys_dir']}/#{node['fqdn']}.crt")}
end

execute 'Build Diffie-Hellman' do
  command ". #{easy_rsa_dir}/vars && $OPENSSL dhparam -out ${KEY_DIR}/dh.pem ${KEY_SIZE}"
  not_if { ::File.exists?("#{node['mo_openvpn']['keys_dir']}/dh.pem")}
end

