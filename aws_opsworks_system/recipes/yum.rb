ruby_block "enable keepcache in yum.conf" do
  block do
    rc = Chef::Util::FileEdit.new("/etc/yum.conf")
    rc.search_file_delete_line(/^\s*keepcache\s*=/)
    rc.insert_line_after_match(/^\[main\]$/, "keepcache=1")
    rc.write_file
  end
  only_if do
    ::File.exists?("/etc/yum.conf")
  end
end

ruby_block "disable yum update-motd plugin" do
  block do
    rc = Chef::Util::FileEdit.new("/etc/yum/pluginconf.d/update-motd.conf")
    rc.search_file_replace_line(/^\s*enabled\s*=\s*1\s*$/, "enabled=0")
    rc.write_file
  end
  only_if do
    ::File.exists?("/etc/yum/pluginconf.d/update-motd.conf")
  end
end

bash "install epel" do
  code "rpm -Uvh 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm' && yum-config-manager --save --setopt=epel.skip_if_unavailable=true"
  retries 3
  retry_delay 10
  ignore_failure true
  only_if do
    node["platform"] == "redhat" &&
      Chef::VersionConstraint.new("~> 7.0").include?(node["platform_version"]) &&
      !system("rpm -q epel-release", :out => :close)
  end
end

package "monit" do
  retry_delay 10
  ignore_failure true
  only_if do
    node["platform"] == "redhat" && Chef::VersionConstraint.new("~> 7.0").include?(node["platform_version"])
  end
end
