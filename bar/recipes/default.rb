#
# Cookbook:: bar
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

file "/home/ec2-user/hello.txt" do
  action :create
end
