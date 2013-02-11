#
# Copyright 2010, Opscode, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'sinatra/base'
require 'chef'
require 'chef/node'
require 'chef/mixin/xml_escape'
require 'chef-rundeck/version'
require 'builder'

module ChefRundeck
  class Server < Sinatra::Base
    configure do
      set :views, File.join(File.dirname(__FILE__), '..', 'views')
    end

    include Chef::Mixin::XMLEscape

    class << self
      attr_accessor :config_file
      attr_accessor :username
      attr_accessor :web_ui_url

      def configure
        Chef::Config.from_file(config_file)
        Chef::Log.level = Chef::Config[:log_level]
      end
    end

    get '/' do
      @nodes = Chef::Node.list(true).map{|k, v| chef_to_rundeck(v)}
      builder :nodes
    end

    get '/environment/:environment' do
      @nodes = Chef::Node.list_by_environment(params[:environment], true).map{|k, v| chef_to_rundeck(v)}
      builder :nodes
    end

    get '/domain/:domain' do
      @nodes = Chef::Search::Query.new.search(:node, "domain:#{params[:domain]}")[0].map!{|n| chef_to_rundeck(n)}
      builder :nodes
    end

    get '/search' do
      @nodes = Chef::Search::Query.new.search(:node, params[:q])[0].map{|n| chef_to_rundeck(n)}
      builder :nodes
    end

    private
    def chef_to_rundeck(node)
      # Certain features in Rundeck require the osFamily value to be set to 'unix' to work appropriately. - SRK
      os_family = node[:kernel][:os] =~ /windows/i ? 'windows' : 'unix'

      n = { 
        :name => node[:fqdn],
        :type => "Node",
        :description => node.name,
        :osArch => node[:kernel][:machine],
        :osFamily => os_family,
        :osName => node[:platform],
        :osVersion => node[:platform_version],
        :tags => [node.chef_environment, node.run_list.roles.join(',')].join(','),
        :hostname => node[:fqdn]
      }

      # Optionally use the edit_url if we passed it in on the command line
      if node[:rundeck] && node[:rundeck].has_key?('edit_url')
        n[:edit_url] = %Q{editUrl="#{xml_escape(node[:rundeck][:edit_url])}"}
      elsif Server.web_ui_url
        n[:edit_url] = %Q{editUrl="#{xml_escape(web_ui_url)}/nodes/#{xml_escape(node.name)}/edit"}
      end

      # Allow overriding the username on a per-node basis.
      if node[:rundeck] && node[:rundeck].has_key?('username')
        n[:username] = node[:rundeck][:username]
      else
        n[:username] = Server.username
      end

      return n
    end
  end
end
