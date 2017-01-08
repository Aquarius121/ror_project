# this one is really usefull, because it refreshes your browser once you've made any changes
# $ guard -g livereload start to run guard livereload
# one more thing you need is an extension to your browser: http://feedback.livereload.com/knowledgebase/articles/86242-how-do-i-install-and-use-the-browser-extensions-
# Chrome: enable "Allow access to file URLs"

group 'livereload' do
  guard 'livereload' do
    watch(%r{app/views/.+\.(erb|haml|slim)$})
    watch(%r{app/aggregators/.+\.(rb)$})
    watch(%r{app/controllers/.+\.(rb)$})
    watch(%r{app/models/.+\.(rb)$})
    watch(%r{app/helpers/.+\.rb})
    watch(%r{config/locales/.+\.yml})

    # Rails Assets Pipeline
    watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
  end
end
