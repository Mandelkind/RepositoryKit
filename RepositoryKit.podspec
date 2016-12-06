Pod::Spec.new do |s|
    s.name             = 'RepositoryKit'
    s.version          = '3.0.1'
    s.summary          = 'The Repository Pattern for Networking and Local Storage'
    s.description      = <<-DESC
                            The Repository Pattern in Swift. Where is the place to put your local storage and networking code? Based on promises.
                            DESC
    s.homepage         = 'https://github.com/lucianopolit/RepositoryKit'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Luciano Polit' => 'lucianopolit@gmail.com' }
    s.source           = { :git => 'https://github.com/lucianopolit/RepositoryKit.git', :tag => s.version.to_s }
    s.platform         = :ios, "9.0"
    s.dependency 'PromiseKit/CorePromise', '~> 4.0.0'

    s.subspec 'Core' do |ss|
        ss.source_files = 'Source/Core/*.swift'
    end

    s.subspec 'Util' do |ss|
        ss.source_files = 'Source/Util/*.swift'
        ss.dependency 'RepositoryKit/Core'
    end

    s.subspec 'CRUD' do |ss|
        ss.source_files = 'Source/CRUD/*.swift'
        ss.dependency 'RepositoryKit/Core'
        ss.dependency 'RepositoryKit/Util'
    end

    s.subspec 'Patch' do |ss|
        ss.source_files = 'Source/Patch/*.swift'
        ss.dependency 'RepositoryKit/CRUD'
    end

    s.subspec 'Sync' do |ss|
        ss.source_files = 'Source/Sync/*.swift'
        ss.dependency 'RepositoryKit/CRUD'
    end

    s.subspec 'Bonus' do |ss|
        ss.source_files = 'Source/Bonus/*.swift'
        ss.dependency 'RepositoryKit/Core'
        ss.dependency 'RepositoryKit/Util'
    end

end
