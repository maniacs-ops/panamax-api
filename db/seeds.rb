# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# When you run the Panamax container, a rake task executes to unload and load templates. We are disabling
# the after_create callback here to avoid two sets of unload/loading of templates.

default_source = GithubTemplateRepoProvider.create(name: TemplateRepo::DEFAULT_PROVIDER_NAME)
TemplateRepo.skip_callback(:create, :after, :reload_templates)
TemplateRepo.find_or_create_by(name: 'centurylinklabs/panamax-public-templates') do |repo|
  repo.template_repo_provider = default_source
end
TemplateRepo.set_callback(:create, :after, :reload_templates)
Registry.find_or_create_by(id: 0, name: 'Docker Hub', endpoint_url: 'https://index.docker.io')
