use_inline_resources

action :set do
  if node['rubrik_http_timeout']
    timeout = node['rubrik_http_timeout']
  else
    timeout = 60 # this is the default in the Ruby HTTP library
  end
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'], timeout)
  if token.nil?
    Chef::Log.error ("Something went wrong connecting to the Rubrik cluster")
    exit
  end
  # refresh vcenter servers
  refresh_vcenters = Rubrik::Api::Vcenter.refresh_all_vcenters('https://' + node['rubrik_host'], token, timeout)
  if refresh_vcenters == false
    Chef::Log.error ("Something went wrong refreshing the vCenter inventories")
  else
    Chef::Log.info ("All vCenters refreshed successfully")
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token, timeout)
  new_resource.updated_by_last_action(true)
end
