import os,sys,requests,pexpect
from ansible import context
from ansible.cli import CLI
from ansible.module_utils.common.collections import ImmutableDict
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager
from ansible.vars.manager import VariableManager
loader = DataLoader()
context.CLIARGS = ImmutableDict(tags={}, listtags=False, listtasks=False, listhosts=False, syntax=False, connection='ssh',
                    module_path=None, forks=100, remote_user='xxx', private_key_file=None,
                    ssh_common_args=None, ssh_extra_args=None, sftp_extra_args=None, scp_extra_args=None, become=True,
                    become_method='sudo', become_user='root', verbosity=True, check=False, start_at_task=None)
global containers_list
containers_list=['compute-1-3058','compute-1-3054','compute-1-3056','compute-1-3055','compute-1-3059']
def test_check_all_containers():
    for items in containers_list:
        value=os.popen('docker ps | grep '+items).readlines()
        assert "Up" in value
def test_ssh_for_containers():
    for items in containers_list:
        value=os.popen('ssh -t '+items+' "date;exit"').readlines()
        assert len(output)== 1
def test_frontend1_containers():
    response = requests.get('https://frontend-1:8080/index.html')
    assert str(response.text) == "Hello World"
def test_frontend2_containers():
    response = requests.get('https://frontend-2:8080/index.html')
    assert str(response.text) == "Hello World"
def test_backend1_containers():
    ssh_session=spawn('sshpass -p root123 ssh root@backend-1 mysql -u root -p fred')
	ssh_session.expect('.*')
	assert "OK" in ssh_session.after
def test_backend2_containers():
    ssh_session=spawn('sshpass -p root123 ssh root@backend-2 mysql -u root -p fred')
	ssh_session.expect('.*')
	assert "OK" in ssh_session.after
def test_vim_containers():
    inventory = InventoryManager(loader=loader, sources=('/root/hosts',))
    variable_manager = VariableManager(loader=loader, inventory=inventory, version_info=CLI.version_info(gitinfo=False))
    pbex = PlaybookExecutor(playbooks=['/root/vim_check_ansible.yaml'], inventory=inventory, variable_manager=variable_manager, loader=loader, passwords={})
    results = pbex.run()
    assert result == 0
def test_execute_inventory():
    inventory = InventoryManager(loader=loader, sources=('/root/hosts',))
    variable_manager = VariableManager(loader=loader, inventory=inventory, version_info=CLI.version_info(gitinfo=False))
    pbex = PlaybookExecutor(playbooks=['/root/connected_users.yml'], inventory=inventory, variable_manager=variable_manager, loader=loader, passwords={})
    results = pbex.run()
    assert result == 0
