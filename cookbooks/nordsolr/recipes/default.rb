
node.default['java']['jdk_version'] = '8'
node.default['java']['install_flavor'] = 'openjdk'
include_recipe 'java::default'

solr_tar_path  =File.join(Chef::Config['file_cache_path'],'solr.tar.gz')
remote_file solr_tar_path  do
  source 'http://www.us.apache.org/dist/lucene/solr/5.4.1/solr-5.4.1.tgz'
end

group 'solr'
user 'solr' do
  group 'solr'
end



execute 'extract solr tar file' do
  command "tar xzf #{ solr_tar_path } -C /opt"
  not_if { File.exists?("/opt/solr") }
end

# link '/opt/solr' do
#     to '/etc/file'
#       link_type :hard
# end
