import click
from ape import project
from ape.api.networks import LOCAL_NETWORK_NAME
from ape.cli import NetworkBoundCommand, ape_cli_context, network_option


@click.command(cls=NetworkBoundCommand)
@ape_cli_context()
@network_option()
def cli(cli_ctx, network):
    """Deploy the NFT contract."""

    network = cli_ctx.provider.network.name
    if network == LOCAL_NETWORK_NAME or network.endwith("-fork"):
        owner = cli_ctx.account_manager.test_accounts[0]
    else:
        owner = cli_ctx.account_manager.load("main")

    owner.deploy(project.JulesAvatar)
