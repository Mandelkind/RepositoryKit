Pod::Spec.new do |s|
    s.name             = 'RepositoryKit'
    s.version          = '1.1.0'
    s.summary          = 'Repositories pattern for networking and storage'
    s.description      = <<-DESC
                            Repository Pattern Swift. Where is the place to put your storage and networking code? Based on promises.
                            DESC
    s.homepage         = 'https://github.com/lucianopolit/RepositoryKit'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Luciano Polit' => 'lucianopolit@gmail.com' }
    s.source           = { :git => 'https://github.com/lucianopolit/RepositoryKit.git', :tag => s.version.to_s }
    s.source_files     = 'Source/**/*.swift'
    s.platform         = :ios, "9.0"
    s.dependency 'PromiseKit', '~> 3.2.0'
end
