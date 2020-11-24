# RHCOS Small ISO Generation for IPv6 deployments

1. Load the required Machine Config and Machine Config Pool in your cluster
2. Generate the CSV file with the networking information for your environment
3. Edit the `env` file to match your environment needs
4. Run the iso generation, you need to provide the API DNS Record and the Webserver IP that will host the rootfs and the ignition configs.

   ~~~sh
   source ./env && make recreate
   ~~~
5. Move the artifacts on the build folder to the root of your webserver

   ~~~sh
   source ./env && make move_artifacts
   ~~~
