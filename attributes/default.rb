# Certificates parameters.
default['mo_openvpn']['install_dir']                      = '/etc/openvpn'
default['mo_openvpn']['easy_rsa_install_dir']             = '/usr/share/easy-rsa'

default['mo_openvpn']['key']['country']                   = 'AR'
default['mo_openvpn']['key']['province']                  = 'Buenos Aires'
default['mo_openvpn']['key']['city']                      = 'La Plata'
default['mo_openvpn']['key']['org']                       = 'My organization'
default['mo_openvpn']['key']['ou']                        = 'My organizational unit'
default['mo_openvpn']['key']['email']                     = 'user@domain'

default['mo_openvpn']['ldap']['url']                      = "ldap://ldap.domain"
default['mo_openvpn']['ldap']['basedn']                   = "ou=Usuarios,ou=myou,o=myorg"
default['mo_openvpn']['ldap']['search_filter']            = "(uid=%u)"

# Network configuration.
default['mo_openvpn']['config']['server']                 = '10.8.0.0 255.255.255.0'

# Server specific
# client 'push routes', attribute is treated as a helper
default['mo_openvpn']['push_routes']                      = [ "192.168.0.0 255.255.255.0" ]
