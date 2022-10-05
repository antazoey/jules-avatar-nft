import pytest


@pytest.fixture(scope="session")
def owner(accounts):
    return accounts[0]


@pytest.fixture(scope="session")
def receiver(accounts):
    return accounts[1]


@pytest.fixture(scope="session")
def nft(owner, project):
    return owner.deploy(project.JulesAvatar)


@pytest.fixture(scope="session")
def base_uri():
    return "ipfs://QmRC6SV8LjQxWTw4jQgjYubysDZh8y68NxXUujyJgEzbLm"
