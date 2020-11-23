# RHCOS Small ISO Generation for IPv6 deployments

1. Load the required Machine Config and Machine Config Pool in your cluster
2. Generate the CSV file with the networking information for your environment
3. Run the iso generation, you need to provide the API DNS Record and the Webserver IP that will host the rootfs and the ignition configs.

   ~~~sh
   API_EP=api.cluster.example.com WEBSERVER=2620:52:0:1304::1 make recreate
   ~~~
4. Move the artifacts on the build folder to the root of your webserver
