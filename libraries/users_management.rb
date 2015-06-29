def mo_openvpn_create_users(users)
  users.each do |user|

    execute "notify_admin_about_#{user}" do
      command <<-SCRIPT
        echo 'Se adjuntan certificados del usuario #{user} para el servidor #{node['fqdn']}.' |
        mutt #{node['mo_openvpn']['admin_email']} \
          -s '[VPN] Nuevo certificado para #{user} en #{node['hostname']}' \
          -a '#{node['mo_openvpn']['keys_dir']}/#{user}.zip'
      SCRIPT
      action :nothing
    end

    execute "package_for_#{user}" do
      command package_configuration_for user
      action :nothing
      notifies :run, "execute[notify_admin_about_#{user}]", :immediately
    end

    template "/tmp/#{template_name_for user}" do
      source 'sample-config.erb'
      action :nothing
      notifies :run, "execute[package_for_#{user}]", :immediately
      variables({
        server_name: node['fqdn'],
        user: user
      })
    end

    execute "Create new user #{user}" do
      command ". #{easy_rsa_dir}/vars && #{easy_rsa_dir}/build-key --batch #{user}"
      not_if "grep '#{mo_openvpn_user_id user}' #{mo_openvpn_index} | grep ^V"
      notifies :create, "template[/tmp/#{template_name_for user}]", :immediately
    end

  end
end

def mo_openvpn_revoke_users(users)
  users_to_not_revoke = users.map { |user| mo_openvpn_user_id user }.join('|')

  cmd = Mixlib::ShellOut.new("egrep -v '(#{users_to_not_revoke})' #{mo_openvpn_index} | grep ^V | grep -v #{mo_openvpn_server_id}")
  cmd.run_command

  cmd.stdout.split("\n").each do |x|
    user = x.match(/\/CN=([\w._-]+)\//)
    if user
      user = user[1]
      execute "Revoke user user #{user}" do
        command ". #{easy_rsa_dir}/vars && #{easy_rsa_dir}/revoke-full #{user}"
        returns [0, 2]
      end
    end
  end
end

def package_configuration_for(user)
  "zip -j #{mo_openvpn_keys_dir}/#{user}.zip /tmp/#{template_name_for user} #{mo_openvpn_keys_dir}/#{user}.key #{mo_openvpn_keys_dir}/#{user}.crt #{mo_openvpn_keys_dir}/ca.crt"
end

def template_name_for(user)
  "#{node['hostname']}_#{user}.conf"
end
