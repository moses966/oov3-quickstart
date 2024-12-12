from ape import accounts, project

def main():
    deployer = accounts.load("my_wallet")

    deployer.deploy(project.OOV3_QuickStart)

if __name__ == "__main__":
    main()