#########################
# :pull_if_missing, :pull
#########################

# default action, default properties
docker_image 'hello-world'

# non-default name attribute, containing a single quote
docker_image "Tom's container" do
  repo 'tduffield/testcontainerd'
end

# :pull action specified
docker_image 'busybox' do
  action :pull
end

# :pull_if_missing
docker_image 'debian' do
  action :pull_if_missing
end

# specify a tag
docker_image 'alpine' do
  tag '3.1'
end

#########
# :remove
#########

# install something so it can be used to test the :remove action
execute 'pull vbatts/slackware' do
  command 'docker pull vbatts/slackware ; touch /marker_image_slackware'
  creates '/marker_image_slackware'
  action :run
end

docker_image 'vbatts/slackware' do
  action :remove
end

########
# :save
########

docker_image 'save hello-world' do
  repo 'hello-world'
  destination '/hello-world.tar'
  not_if { ::File.exist? '/hello-world.tar' }
  action :save
end

########
# :build
########

# Build from a Dockerfile
directory '/usr/local/src/container1' do
  action :create
end

cookbook_file '/usr/local/src/container1/Dockerfile' do
  source 'Dockerfile_1'
  action :create
end

docker_image 'someara/image-1' do
  tag 'v0.1.0'
  source '/usr/local/src/container1/Dockerfile'
  force true
  not_if { ::File.exist? '/marker_image_image-1' }
  action :build
end

file '/marker_image_image-1' do
  action :create
end

# Build from a directory
directory '/usr/local/src/container2' do
  action :create
end

file '/usr/local/src/container2/foo.txt' do
  content 'Dockerfile_2 contains ADD for this file'
  action :create
end

cookbook_file '/usr/local/src/container2/Dockerfile' do
  source 'Dockerfile_2'
  action :create
end

docker_image 'someara/image.2' do
  tag 'v0.1.0'
  source '/usr/local/src/container2'
  action :build_if_missing
end

# Build from a tarball
cookbook_file '/usr/local/src/image_3.tar' do
  source 'image_3.tar'
  action :create
end

docker_image 'image_3' do
  tag 'v0.1.0'
  source '/usr/local/src/image_3.tar'
  action :build_if_missing
end

#########
# :import
#########

docker_image 'hello-again' do
  tag 'v0.1.0'
  source '/hello-world.tar'
  action :import
end

################
# :tag and :push
################

# Test dots and dashes in repo names

# [GH-356]

docker_image 'someara/name-w-dashes'

# # for pushing to public repo
# docker_tag 'public repo tag for name-w-dashes:v1.0.1' do
#   target_repo 'hello-again'
#   target_tag 'v0.1.0'
#   to_repo 'someara/name-w-dashes'
#   to_tag 'latest'
#   action :tag
# end

# for pushing to private repo
docker_tag 'private repo tag for name-w-dashes:v1.0.1' do
  target_repo 'hello-again'
  target_tag 'v0.1.0'
  to_repo 'localhost:5043/someara/name-w-dashes'
  to_tag 'latest'
  action :tag
end

# FIXME: name.w.dots broken right now

# # for pushing to public repo
# docker_tag 'public repo tag for name.w.dots' do
#   target_repo 'busybox'
#   target_tag 'latest'
#   to_repo 'someara/name.w.dots'
#   to_tag 'latest'
#   action :tag
# end

# # for pushing to private repo
docker_tag 'private repo tag for name.w.dots' do
  target_repo 'busybox'
  target_tag 'latest'
  to_repo 'localhost:5043/someara/name.w.dots'
  to_tag 'latest'
  action :tag
end

include_recipe 'docker_test::registry'

# AUTH

# docker_registry 'https://index.docker.io/v1/' do
#   username 'youthere'
#   password 'p4sswh1rr3d'
#   email 'youthere@computers.biz'
# end

docker_registry 'localhost:5043' do
  username 'testuser'
  password 'testpassword'
  email 'alice@computers.biz'
end

# # comment me out
# docker_image 'someara/hello-again' do
#   not_if { ::File.exist? '/marker_image_public_name-w-dashes' }
#   action :push
# end

# # comment me out
# file '/marker_image_public_name-w-dashes' do
#   action :create
# end

docker_image 'localhost:5043/someara/name-w-dashes' do
  not_if { ::File.exist? '/marker_image_private_name-w-dashes' }
  action :push
end

file '/marker_image_private_name-w-dashes' do
  action :create
end

# # comment me out
# docker_image 'someara/name.w.dots' do
#   not_if { ::File.exist? '/marker_image_public_name.w.dots' }
#   action :push
# end

# # comment me out
# file '/marker_image_public_name.w.dots' do
#   action :create
# end

docker_image 'localhost:5043/someara/name.w.dots' do
  not_if { ::File.exist? '/marker_image_private_name.w.dots' }
  action :push
end

file '/marker_image_private_name.w.dots' do
  action :create
end
