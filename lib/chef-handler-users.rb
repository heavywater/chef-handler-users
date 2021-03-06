# Author:: AJ Christensen <aj@hw-ops.com>
# Copyright:: 2012, Heavy Water Operations, LLC (OR)
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'
require 'chef/handler'
require 'pony'

class Chef::Handler::Users < Chef::Handler
  attr_reader :config
  class ConfigurationError < StandardError; end

  def initialize(config={})
    @config = config

    %w[to from].each do |key|
      unless @config.has_key? key
        raise ConfigurationError.new("Required configuration #{key} not passed to handler")
      end
    end

    if @config[:via] == 'smtp' && !@config[:via_options]
      raise ConfigurationError.new("via_options is required for smtp")
    end
  end

  def report
    updated_users = run_status.updated_resources.select do |resource|
      resource.resource_name == :user
    end

    if updated_users.empty?
      Chef::Log.info "Users handler detected no user changes"
      return
    else
      Chef::Log.info "Users handler detected #{updated_users.length} user changes. Generating summary email for #{@config[:to]}"
    end

    subject = "Chef run on #{node.name} at #{Time.now} resulted in change of #{updated_users.length} users"

    message = generate_email_body(updated_users)

    Pony.mail(
      ensure_hash(@config).update(
        :subject => subject,
        :body => message
      )
    )
  end

  def generate_email_body users
    users.inject([]) do |body, user|
      body << summary_for_user(user)
      body
    end.join("\n")
  end

  def summary_for_user user
    <<-EOH
User #{user.name} updated:
- resource action: #{user.action}
- comment (GECOS): #{user.comment}
- system username: #{user.username}
- system uid: #{user.uid}
- system gid: #{user.gid}
- system shell: #{user.shell}
- system user: #{user.system}
    EOH
  end

  def ensure_hash(hash_thing)
    new_h = {}
    hash_thing.to_hash.each do |k,v|
      new_h[k.to_sym] = v.kind_of?(Hash) || v.kind_of?(Chef::Node::Attribute) ? ensure_hash(v) : v
    end
    new_h
  end

end
