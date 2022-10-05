import click
from ape import project
from ape.api.networks import LOCAL_NETWORK_NAME
from ape.cli import NetworkBoundCommand, ape_cli_context, get_user_selected_account, network_option


# default connect to a provider
def main():
    account = get_user_selected_account()
    account.deploy(project.NFT)


# perk you can add args unlike main method
@click.command(cls=NetworkBoundCommand)
@click.option("--uri", help="base uri for nft", default="dummy value")
@ape_cli_context()
@network_option()
# cli_ctx must go first
def cli(cli_ctx, network, uri):
    """
    Deploy the nft
    """
    network = cli_ctx.provider.network.name
    if network == LOCAL_NETWORK_NAME or network.endwith("-fork"):
        account = cli_ctx.account_manager.test_accounts[0]
    else:
        account = get_user_selected_account()

    account.deploy(project.NFT, uri)
