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
    return "ipfs://QmbYVQXcibEoRrdGrF1zh9i1mkXVB3vtPzLA9BFYicKuGc"
