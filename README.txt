1. Run the Buildenv.sh script for creating the entire setup from end to end.
   Command to run (./Buildenv.sh)
2. Vagrant file consists environment for docker.
2. It has three Docker files
   Dockerfile1---frontend containers
   Dockerfile2---backend containers
   Dockerfile3---controller conatiner
3. The playbook vim_check_ansible yaml and hosts file for checking the vim package.
4. The playbook connected_users.yml for collecting inventory with hosts files.
5. Host file is an ansible inventory with all the hosts
6. date.sh is an shell script for creating a string with nodename,date,timestamp.
7. To test the entire environment an test_cases.py (pytest) script is written.
   Command to run (py.test test_cases.py)
