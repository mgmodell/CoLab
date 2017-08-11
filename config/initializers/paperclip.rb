# config/initializers/paperclip.rb
# The following was pulled from http://bit.ly/2vsRVZS to avoid international endpoint issue.
Paperclip::Attachment.default_options[:s3_host_name] = 's3.ap-northeast-2.amazonaws.com'
