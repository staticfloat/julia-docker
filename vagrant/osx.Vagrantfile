Vagrant.configure(2) do |config|
# Add each build-* target to the buildall target
    # Build "buildworker" vm which gets the whole kit and kaboodle
    config.vm.define "buildworker" do |worker|
        worker.vm.box = "{box_name}"
        worker.vm.provider "virtualbox" do |vb|
            vb.cpus = 4
            vb.memory = 8192
        end
        worker.vm.provision "file", source: "lib/secret/buildbot_secret.sh", destination: "/tmp/secret.sh", run: "always"
        worker.vm.provision "shell", path: "lib/buildbot_setup.sh", args: "{buildworker_name}", upload_path: "/tmp/buildbot_setup.sh", run: "always"

        # Also provision in our secret codesigning stuff
        worker.vm.provision "file", source: "lib/secret/osx.p12", destination: "/tmp/julia.p12", run: "always"
        worker.vm.provision "shell", path: "lib/osx_codesign.sh", run: "always"
    end

    # Build "tabularasa" vm, which comes from the same base box, but has less memory and CPUs, and doesn't get the codesigning stuff
    config.vm.define "tabularasa" do |tr|
        tr.vm.box = "{box_name}"
        tr.vm.provider "virtualbox" do |vb|
            vb.cpus = 2
            vb.memory = 2048
        end
        tr.vm.provision "file", source: "lib/secret/buildbot_secret.sh", destination: "/tmp/secret.sh", run: "always"
        tr.vm.provision "shell", path: "lib/buildbot_setup.sh", args: "tabularasa_{buildworker_name}", upload_path: "/tmp/buildbot_setup.sh", run: "always"
    end
end
