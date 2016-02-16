# INSTALL JAVA
node.default['java']['jdk_version'] = '8'
node.default['java']['install_flavor'] = 'openjdk'
include_recipe 'java::default'

# INSTALL EC2 TOOLS
['vim','lsof','ruby', 'rsync'].each do |p|
  package p
end

ec2_rpm_path = File.join(Chef::Config['file_cache_path'],'ec2-ami-tools.noarch.rpm')
remote_file ec2_rpm_path  do
  source 'http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.noarch.rpm'
end

rpm_package 'ec2-ami-tools.noarch' do
  source ec2_rpm_path
end

# INSTALL SOLR
solr_version = '5.4.1'
solr_tar_path  =File.join(Chef::Config['file_cache_path'],'solr.tar.gz')
remote_file solr_tar_path  do
  source "http://www.us.apache.org/dist/lucene/solr/#{ solr_version }/solr-#{ solr_version }.tgz"
end

group 'solr'
user 'solr' do
  group 'solr'
end

solr_directory = "/opt/solr-#{ solr_version }"

execute 'extract solr tar file' do
  command <<-EOS
  tar xzf #{ solr_tar_path } -C /opt
  chown -R solr:solr #{ solr_directory }
  EOS
  not_if { File.exists?(File.join(solr_directory, "LICENSE.txt")) }
end

link '/opt/solr' do
    to solr_directory
end

file "/etc/init.d/solr" do
  owner 'root'
  group 'root'
  mode 0744
  content ::File.open(File.join(solr_directory,"bin","init.d","solr")).read
  action :create
end

# this is the file with all of the
# juicy solr settings like java heap size
# and gc options
template '/etc/default/solr.in.sh' do
  owner 'root'
  group 'root'
  mode 0644
  source 'solr.in.sh.erb'
end

template '/var/solr/log4j.properties' do
  owner 'solr'
  group 'solr'
  source 'log4j.properties.erb'
end

['/var/solr/data','/var/log/solr'].each do |d|
  directory d do
    owner 'solr'
    group 'solr'
    recursive true
  end
end

service 'solr' do
  action :enable
end
