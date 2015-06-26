users = data_bag_item(node['mo_openvpn']['databag'], node['mo_openvpn']['databag_item'])['users']

mo_openvpn_create_users users
mo_openvpn_revoke_users users
