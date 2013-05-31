unless Rails.env.production? || Rails.env.staging?
  namespace :jenkins do

    desc "Clean reports"
    task :clean do
      sh %{rm -rf spec/reports}
    end

    desc "Run all specs"
    RSpec::Core::RakeTask.new do |t|
      t.name = 'spec'
      t.rspec_opts = %w{--require ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec --format documentation --no-drb --colour}
      t.pattern = '**/spec/'
    end

    desc "Clean reports and run specs"
    task :all => [ :clean, "jenkins:spec" ] do

    end
  end
end
