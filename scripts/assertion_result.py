from ape import accounts, project
from .address import load_contract_address

def main():
    deployer = accounts.load("my_wallet")
    address = load_contract_address()
    contract = project.OOV3_QuickStart.at(address)

    # return assertion result
    result = contract.getAssertionResult()
    print(f"Assertion Result: {result}")

if __name__ == "__main__":
    main()