require 'usmu/helpers/indexer'

class Usmu::Github::Pages::Configuration
  include Usmu::Helpers::Indexer

  indexer :@config

  def initialize(config)
    @config = config
  end

  # If this is a *.github.io repository then there's a good chance we're
  # dealing with a repository that must be built to the master branch.
  # Otherwise this is a gh-pages branch repository.
  def default_branch(remote)
    remote_url = `git config remote.#{Shellwords.escape remote}.url`.chomp
    repo_name = begin
      URI.parse(remote_url).path[1..-5]
    rescue ::URI::InvalidURIError
      remote_url.split(':', 2).last[0..-5]
    end

    if File.basename(repo_name).end_with? '.github.io'
      'master'
    else
      'gh-pages'
    end
  end
end
